# frozen_string_literal: true

require 'spec_helper'
require 'benchmark'
require 'objspace'
require 'allocation_stats'
require 'benchmark/memory'

class AMSResourceSerializer < ActiveModel::Serializer
  attributes :id, :email, :phone

  attribute(:string_id, if: -> { instance_options[:stringify] }) { object.id.to_s }
  attribute(:float_id, unless: -> { instance_options[:stringify] }) { object.id.to_f }
  attribute(:full_name) { instance_options[:only_first_name] ? object.first_name : "#{object.first_name} #{object.last_name}" }

  has_one :has_one_relationship, serializer: AMSResourceSerializer
  has_many :has_many_relationship, serializer: AMSResourceSerializer
end

class FSResourceSerializer
  include FastSerializer::Schema::Mixin

  attributes :id, :email, :phone

  attribute(:string_id, if: proc { params[:stringify] }) { resource.id.to_s }
  attribute(:float_id, unless: proc { params[:stringify] }) { resource.id.to_f }
  attribute(:full_name) { params[:only_first_name] ? resource.first_name : "#{resource.first_name} #{resource.last_name}" }

  has_one :has_one_relationship, serializer: FSResourceSerializer
  has_many :has_many_relationship, serializer: FSResourceSerializer
end

RSpec.describe 'Performance', performance: true do

  before(:all) { GC.disable }
  before(:all) { GC.enable }

  describe 'speed benchmarks' do
    it 'creates a hash of 100 records under 2ms ' do
      resources = build_list :resource, 100

      expect {
        FSResourceSerializer.new(resources).serializable_hash
      }.to perform_faster_than {
        ActiveModelSerializers::SerializableResource.new(resources, each_serializer: AMSResourceSerializer).as_json
      }.at_least(5).times
    end

    it 'creates a hash of 100 records with dependencies under 4ms ' do
      resources = build_list :resource, 100, :has_many_relation, :has_one_relation

      expect {
        FSResourceSerializer.new(resources).serializable_hash
      }.to perform_faster_than {
        ActiveModelSerializers::SerializableResource.new(resources, each_serializer: AMSResourceSerializer).as_json
      }.at_least(5).times

    end

    it 'creates a hash of 1000 records under 15ms ' do
      resources = build_list :resource, 1000
      expect { FSResourceSerializer.new(resources).serializable_hash }.to perform_under(15).ms
    end

    it 'creates a hash of 1000 records with dependencies under 25ms ' do
      resources = build_list :resource, 1000, :has_many_relation, :has_one_relation
      expect {
        FSResourceSerializer.new(resources).serializable_hash
      }.to perform_faster_than {
        ActiveModelSerializers::SerializableResource.new(resources, each_serializer: AMSResourceSerializer).as_json
      }.at_least(10).times
    end
  end

  describe 'memory utilization' do



    specify 'allocation test' do
      resources = build_list :resource, 100

      stats = AllocationStats.trace {
        FSResourceSerializer.new(resources).serializable_hash
      }

      puts stats
            .allocations
            .group_by(:sourcefile, :sourceline, :class, :method_id)
            .sort_by_count
            .to_text

    end


    allocation_factor = 6
    it "allocates less memory #{allocation_factor}x" do

      resources = build_list :resource, 1000

      20.times { FSResourceSerializer.new(resources).serializable_hash }
      20.times { ActiveModelSerializers::SerializableResource.new(resources, each_serializer: AMSResourceSerializer).as_json }

      job = Benchmark::Memory::Job.new

      job.report('fast-serializer') { FSResourceSerializer.new(resources).serializable_hash }
      job.report('active-model-serializer') { ActiveModelSerializers::SerializableResource.new(resources, each_serializer: AMSResourceSerializer).as_json }

      job.run
      job.full_report
      job.compare!
      job.run_comparison

      measurements_map = job.full_report.comparison.entries.map { |comp_entry| [comp_entry.label, comp_entry.measurement] }.to_h

      allocation = -> (name) { measurements_map[name].objects.allocated }
      mem_cons = -> (name) { measurements_map[name].memory.allocated }

      expect(allocation.('fast-serializer') * allocation_factor).to be < allocation.('active-model-serializer')
      expect(mem_cons.('fast-serializer') * allocation_factor) .to be < mem_cons.('active-model-serializer')
    end
  end

  # copy-pasted from here
  # https://github.com/Netflix/fast_jsonapi/blob/release-1.5/spec/lib/object_serializer_performance_spec.rb#L148
  context 'comprasion' do
    SERIALIZERS = {
      fjs: {
        name: 'Fast Serializer',
        hash_method: :serializable_hash,
        json_method: :serialized_json
      },
      ams: {
        name: 'AMS serializer',
        speed_factor: 6,
        hash_method: :as_json
      }
    }.freeze

    def print_stats(message, count, data)
      puts
      puts message

      name_length = SERIALIZERS.collect { |s| s[1].fetch(:name, s[0]).length }.max

      puts format("%-#{name_length + 1}s %-10s %-10s %s", 'Serializer', 'Records', 'Time', 'Speed Up')

      report_format = "%-#{name_length + 1}s %-10s %-10s"
      fjs = data[:fjs][:time]
      puts format(report_format, 'Fast serializer', count, fjs.round(2).to_s + ' ms')

      data.reject { |k, _v| k == :fjs }.each_pair do |k, v|
        t = v[:time]
        factor = t / fjs

        speed_factor = SERIALIZERS[k].fetch(:speed_factor, 1)
        result = factor >= speed_factor ? '✔' : '✘'

        puts format("%-#{name_length + 1}s %-10s %-10s %sx %s", SERIALIZERS[k][:name], count, t.round(2).to_s + ' ms', factor.round(2), result)
      end
    end

    def run_hash_benchmark(message, movie_count, serializers)
      data = Hash[serializers.keys.collect { |k| [k, { hash: nil, time: nil, speed_factor: nil }] }]

      serializers.each_pair do |k, v|
        hash_method = SERIALIZERS[k].key?(:hash_method) ? SERIALIZERS[k][:hash_method] : :to_hash
        data[k][:time] = Benchmark.measure { data[k][:hash] = v.public_send(hash_method) }.real * 1000
      end

      print_stats(message, movie_count, data)

      data
    end

    context 'when comparing with AMS 0.10.x' do
      [1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610].each do |resource_count|
        it "should serialize #{resource_count} records atleast #{SERIALIZERS[:ams][:speed_factor]} times faster than AMS" do
          resources = build_list :resource, resource_count

          serializers = {
            fjs: FSResourceSerializer.new(resources),
            ams: ActiveModelSerializers::SerializableResource.new(resources, each_serializer: AMSResourceSerializer)
          }

          message = "Serialize to Ruby Hash #{resource_count} records"
          hash_benchmarks = run_hash_benchmark(message, resource_count, serializers)

          # hash
          hash_speed_up = hash_benchmarks[:ams][:time] / hash_benchmarks[:fjs][:time]
          expect(hash_speed_up).to be >= SERIALIZERS[:ams][:speed_factor]
        end
      end
    end

    context 'when, comparing with AMS 0.10.x and with includes' do
      [1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610].each do |resource_count|
        it "should serialize #{resource_count} records atleast #{SERIALIZERS[:ams][:speed_factor]} times faster than AMS" do
          resources = build_list :resource, resource_count, :has_many_relation, :has_one_relation
          options = {}

          serializers = {
            # panko: Panko::ArraySerializer.new(resources, each_serializer: panko_serializer),
            fjs: FSResourceSerializer.new(resources, options),
            ams: ActiveModelSerializers::SerializableResource.new(
              resources,
              each_serializer: AMSResourceSerializer,
              **options
            )
          }

          message = "Serialize to Ruby Hash #{resource_count} with includes and meta"
          hash_benchmarks = run_hash_benchmark(message, resource_count, serializers)

          # hash
          hash_speed_up = hash_benchmarks[:ams][:time] / hash_benchmarks[:fjs][:time]
          expect(hash_speed_up).to be >= SERIALIZERS[:ams][:speed_factor]
        end
      end
    end
  end
end

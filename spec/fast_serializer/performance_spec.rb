# frozen_string_literal: true

require 'spec_helper'
require 'benchmark'

RSpec.describe 'Performance', performance: true do
  include_context :fjs_serializer
  include_context :ams_serializer
  include_context :panko_serializer

  before(:all) { GC.disable }
  before(:all) { GC.enable }

  it 'creates a hash of 100 records under 2ms ' do
    resources = build_list :resource, 100

    expect {
      serializer.new(resources).serializable_hash
    }.to perform_faster_than {
      ActiveModelSerializers::SerializableResource.new(resources, each_serializer: ams_serializer).as_json
    }.at_least(5).times
  end

  it 'creates a hash of 100 records with dependencies under 4ms ' do
    resources = build_list :resource, 100, :has_many_relation, :has_one_relation

    expect {
      serializer.new(resources).serializable_hash
    }.to perform_faster_than {
      ActiveModelSerializers::SerializableResource.new(resources, each_serializer: ams_serializer).as_json
    }.at_least(5).times

  end

  it 'creates a hash of 1000 records under 10ms ' do
    resources = build_list :resource, 1000
    expect { serializer.new(resources).serializable_hash }.to perform_under(7).ms
  end

  it 'creates a hash of 1000 records with dependencies under 25ms ' do
    resources = build_list :resource, 1000, :has_many_relation, :has_one_relation
    expect {
      serializer.new(resources).serializable_hash
    }.to perform_faster_than {
      ActiveModelSerializers::SerializableResource.new(resources, each_serializer: ams_serializer).as_json
    }.at_least(10).times
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
        speed_factor: 3,
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

    def run_json_benchmark(message, movie_count, serializers)
      data = Hash[serializers.keys.collect { |k| [k, { json: nil, time: nil, speed_factor: nil }] }]

      serializers.each_pair do |k, v|
        json_method = SERIALIZERS[k].key?(:json_method) ? SERIALIZERS[k][:json_method] : :to_json
        data[k][:time] = Benchmark.measure { data[k][:json] = v.public_send(json_method) }.real * 1000
      end

      print_stats(message, movie_count, data)

      data
    end

    context 'when comparing with AMS 0.10.x' do
      [1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610].each do |resource_count|
        it "should serialize #{resource_count} records atleast #{SERIALIZERS[:ams][:speed_factor]} times faster than AMS" do
          resources = build_list :resource, resource_count

          serializers = {
            fjs: fjs_serializer.new(resources),
            ams: ActiveModelSerializers::SerializableResource.new(resources, each_serializer: ams_serializer)
          }

          # message = "Serialize to JSON string #{resource_count} records"
          # json_benchmarks  = run_json_benchmark(message, resource_count, serializers)

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
            fjs: fjs_serializer.new(resources, options),
            ams: ActiveModelSerializers::SerializableResource.new(
              resources,
              each_serializer: ams_serializer,
              **options
            )
          }

          # message = "Serialize to JSON string #{resource_count} with includes and meta"
          # json_benchmarks = run_json_benchmark(message, resource_count, serializers)

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

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Mixin tests' do
  let(:resource) { build :resource, :has_one_relation, :has_many_relation }

  let(:serializer) do
    class TestSerializer
      include FastSerializer::Schema::Mixin

      attribute(:id)
      attribute(:email)
      attribute(:full_name) { "#{resource.first_name} #{resource.last_name}" }
      attribute(:phone)
      attribute(:object_first_name, if: proc { params[:object] }) { object.first_name }
      has_one(:has_one_relationship, serializer: self)
      has_many(:has_many_relationship, serializer: self)

      attribute(:foobar, if: proc { params[:include_weird_attribute] } ) do
        weird_attribute
      end

      def weird_attribute
        'foobar'
      end

    end

    TestSerializer
  end

  it 'allows to specify schema' do
    serializable_hash = serializer.new(resource).serializable_hash

    expect(serializable_hash[:email]).to eq(resource.email)
    expect(serializable_hash[:id]).to eq(resource.id)
    expect(serializable_hash[:full_name]).to eq "#{resource.first_name} #{resource.last_name}"
    expect(serializable_hash[:phone]).to eq(resource.phone)

    has_one_relationship_hash = serializable_hash[:has_one_relationship]
    expect(has_one_relationship_hash[:email]).to eq(resource.has_one_relationship.email)
    expect(has_one_relationship_hash[:full_name]).to eq("#{resource.has_one_relationship.first_name} #{resource.has_one_relationship.last_name}")
    expect(has_one_relationship_hash[:id]).to eq(resource.has_one_relationship.id)
    expect(has_one_relationship_hash[:phone]).to eq(resource.has_one_relationship.phone)
  end

  it 'implements ams-like #object API' do
    serializable_hash = serializer.new(resource, object: true).serializable_hash
    expect(serializable_hash[:object_first_name]).to eq resource.first_name
  end

  it 'serializes meta' do
    schema = serializer.new(resource, meta: { foo: 'bar' })

    serializable_hash = schema.serializable_hash
    expect(serializable_hash[:meta]).to be_present
    expect(serializable_hash[:has_one_relationship][:meta]).to be_blank
  end

  it 'serializes collection' do
    resources = build_list(:resource, 2)

    schema = serializer.new(resources, meta: { foo: 'bar' })

    serializable_hash = schema.serializable_hash
    expect(serializable_hash).to be_a(Array)

    expect(serializable_hash[0][:email]).to eq(resources[0].email)
    expect(serializable_hash[0][:id]).to eq(resources[0].id)
    expect(serializable_hash[0][:full_name]).to eq "#{resources[0].first_name} #{resources[0].last_name}"
    expect(serializable_hash[0][:phone]).to eq(resources[0].phone)

    expect(serializable_hash[1][:email]).to eq(resources[1].email)
    expect(serializable_hash[1][:id]).to eq(resources[1].id)
    expect(serializable_hash[1][:full_name]).to eq "#{resources[1].first_name} #{resources[1].last_name}"
    expect(serializable_hash[1][:phone]).to eq(resources[1].phone)
  end

  it 'serializes collection with root' do
    resources = build_list(:resource, 2)

    schema = serializer.new(resources, root: :resources)

    serializable_hash = schema.serializable_hash[:resources]

    expect(serializable_hash[0][:email]).to eq(resources[0].email)
    expect(serializable_hash[0][:id]).to eq(resources[0].id)
    expect(serializable_hash[0][:full_name]).to eq "#{resources[0].first_name} #{resources[0].last_name}"
    expect(serializable_hash[0][:phone]).to eq(resources[0].phone)

    expect(serializable_hash[1][:email]).to eq(resources[1].email)
    expect(serializable_hash[1][:id]).to eq(resources[1].id)
    expect(serializable_hash[1][:full_name]).to eq "#{resources[1].first_name} #{resources[1].last_name}"
    expect(serializable_hash[1][:phone]).to eq(resources[1].phone)
  end

  it 'checks include param' do
    schema = serializer.new(resource, include: [:has_many_relationship])

    serializable_hash = schema.serializable_hash

    expect(serializable_hash[:email]).to eq(resource.email)
    expect(serializable_hash[:id]).to eq(resource.id)
    expect(serializable_hash[:full_name]).to eq "#{resource.first_name} #{resource.last_name}"
    expect(serializable_hash[:phone]).to eq(resource.phone)

    has_one_relationship_hash = serializable_hash[:has_one_relationship]
    expect(has_one_relationship_hash).to be_blank
  end

  it 'when include param is nil' do
    schema = serializer.new(resource, include: nil)
    serializable_hash = schema.serializable_hash

    expect(serializable_hash[:email]).to eq(resource.email)
    expect(serializable_hash[:id]).to eq(resource.id)
    expect(serializable_hash[:full_name]).to eq "#{resource.first_name} #{resource.last_name}"
    expect(serializable_hash[:phone]).to eq(resource.phone)

    expect(serializable_hash[:has_one_relationship]).to be_present
    expect(serializable_hash[:has_many_relationship]).to be_present
  end

  it 'serializes to JSON' do
    schema = serializer.new(resource)

    expect(schema.serialized_json).to be_a(String)
    serializable_hash = JSON.parse(schema.serialized_json, symbolize_names: true)

    expect(serializable_hash[:email]).to eq(resource.email)
    expect(serializable_hash[:id]).to eq(resource.id)
    expect(serializable_hash[:full_name]).to eq "#{resource.first_name} #{resource.last_name}"
    expect(serializable_hash[:phone]).to eq(resource.phone)

    has_one_relationship_hash = serializable_hash[:has_one_relationship]
    expect(has_one_relationship_hash[:email]).to eq(resource.has_one_relationship.email)
    expect(has_one_relationship_hash[:full_name]).to eq("#{resource.has_one_relationship.first_name} #{resource.has_one_relationship.last_name}")
    expect(has_one_relationship_hash[:id]).to eq(resource.has_one_relationship.id)
    expect(has_one_relationship_hash[:phone]).to eq(resource.has_one_relationship.phone)
  end

  it 'is bound to schema context' do
    schema = serializer.new(resource, include_weird_attribute: true)
    hash = schema.serializable_hash
    expect(hash[:foobar]).to eq 'foobar'
  end
end

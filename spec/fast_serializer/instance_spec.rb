# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Instance tests' do
  let(:resource) { build :resource, :has_one_relation, :has_many_relation }

  it 'allows to specify schema' do
    schema = FastSerializer::Schema.new(resource)
    schema.attribute(:id)
    schema.attribute(:email)
    schema.attribute(:full_name) { |resource| "#{resource.first_name} #{resource.last_name}" }
    schema.attribute(:phone)
    schema.has_one(:has_one_relationship, serializer: schema)

    serializable_hash = schema.serializable_hash

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

  it 'serializes meta' do
    schema = FastSerializer::Schema.new(resource, meta: { foo: 'bar' })
    schema.attribute(:id)
    schema.attribute(:email)
    schema.attribute(:full_name) { |resource| "#{resource.first_name} #{resource.last_name}" }
    schema.attribute(:phone)
    schema.has_one(:has_one_relationship, serializer: schema)

    serializable_hash = schema.serializable_hash
    expect(serializable_hash[:meta]).to be_present
    expect(serializable_hash[:has_one_relationship][:meta]).to be_blank
  end

  it 'serializes collection' do
    resources = build_list(:resource, 2)

    schema = FastSerializer::Schema.new(resources, meta: { foo: 'bar' })
    schema.attribute(:id)
    schema.attribute(:email)
    schema.attribute(:full_name) { |resource| "#{resource.first_name} #{resource.last_name}" }
    schema.attribute(:phone)
    schema.has_one(:has_one_relationship, serializer: schema)

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

    schema = FastSerializer::Schema.new(resources, meta: { foo: 'bar' })
    schema.root(:resources)
    schema.attribute(:id)
    schema.attribute(:email)
    schema.attribute(:full_name) { |resource| "#{resource.first_name} #{resource.last_name}" }
    schema.attribute(:phone)
    schema.has_one(:has_one_relationship, serializer: schema)

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
    schema = FastSerializer::Schema.new(resource, include: [:has_many_relationship])
    schema.attribute(:id)
    schema.attribute(:email)
    schema.attribute(:full_name) { |resource| "#{resource.first_name} #{resource.last_name}" }
    schema.attribute(:phone)
    schema.has_many(:has_many_relationship, serializer: schema)
    schema.has_one(:has_one_relationship, serializer: schema)

    serializable_hash = schema.serializable_hash

    expect(serializable_hash[:email]).to eq(resource.email)
    expect(serializable_hash[:id]).to eq(resource.id)
    expect(serializable_hash[:full_name]).to eq "#{resource.first_name} #{resource.last_name}"
    expect(serializable_hash[:phone]).to eq(resource.phone)

    has_one_relationship_hash = serializable_hash[:has_one_relationship]
    expect(has_one_relationship_hash).to be_blank
  end

  it 'when include param is empty' do
    schema = FastSerializer::Schema.new(resource, include: [])
    schema.attribute(:id)
    schema.attribute(:email)
    schema.attribute(:full_name) { |resource| "#{resource.first_name} #{resource.last_name}" }
    schema.attribute(:phone)
    schema.has_many(:has_many_relationship, serializer: schema)
    schema.has_one(:has_one_relationship, serializer: schema)

    serializable_hash = schema.serializable_hash

    expect(serializable_hash[:email]).to eq(resource.email)
    expect(serializable_hash[:id]).to eq(resource.id)
    expect(serializable_hash[:full_name]).to eq "#{resource.first_name} #{resource.last_name}"
    expect(serializable_hash[:phone]).to eq(resource.phone)

    expect(serializable_hash[:has_one_relationship]).to be_present
    expect(serializable_hash[:has_many_relationship]).to be_present
  end

  it 'serializes to JSON' do
    schema = FastSerializer::Schema.new(resource)
    schema.attribute(:id)
    schema.attribute(:email)
    schema.attribute(:full_name) { |resource| "#{resource.first_name} #{resource.last_name}" }
    schema.attribute(:phone)
    schema.has_one(:has_one_relationship, serializer: schema)

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
end

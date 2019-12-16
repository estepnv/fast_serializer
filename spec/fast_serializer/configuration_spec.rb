# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FastSerializer do
  describe '.configure' do
    let(:resource) { build :resource, :has_one_relation, :has_many_relation }

    after do
      FastSerializer.configure do |config|
        config.coder = JSON
      end
    end

    it 'allows to specify schema' do
      FastSerializer.configure do |config|
        config.coder = Marshal
      end

      schema = FastSerializer::Schema.new
      schema.attribute(:id)
      schema.attribute(:email)
      schema.attribute(:full_name) { |resource| "#{resource.first_name} #{resource.last_name}" }
      schema.attribute(:phone)
      schema.has_one(:has_one_relationship, schema: schema)

      serializable_hash = Marshal.load(schema.serialize_resource_to_json(resource))

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
end

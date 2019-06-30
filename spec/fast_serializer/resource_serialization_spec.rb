require 'spec_helper'
require 'benchmark'

RSpec.describe "Resource serialization"do
  include_context :fjs_serializer

  subject(:serializable_hash) { serializer_instance.serializable_hash }

  before { puts Benchmark.measure { serializable_hash } }

  it "serializes resource" do
    expect(serializable_hash[:email]).to eq(resource.email)
    expect(serializable_hash[:id]).to eq(resource.id)
    expect(serializable_hash[:full_name]).to eq "#{resource.first_name} #{resource.last_name}"
    expect(serializable_hash[:phone]).to eq(resource.phone)
    expect(serializable_hash[:string_id]).to be_nil

    has_one_relationship_hash = serializable_hash[:has_one_relationship]
    expect(has_one_relationship_hash[:email]).to eq(resource.has_one_relationship.email)
    expect(has_one_relationship_hash[:full_name]).to eq("#{resource.has_one_relationship.first_name} #{resource.has_one_relationship.last_name}")
    expect(has_one_relationship_hash[:id]).to eq(resource.has_one_relationship.id)
    expect(has_one_relationship_hash[:phone]).to eq(resource.has_one_relationship.phone)

    has_many_relationship_hash = serializable_hash[:has_many_relationship]
    has_many_relationship_hash.each.with_index do |relationship_hash, index|
      relationship = resource.has_many_relationship[index]
      expect(relationship_hash[:email]).to eq(relationship.email)
      expect(relationship_hash[:full_name]).to eq("#{relationship.first_name} #{relationship.last_name}")
      expect(relationship_hash[:id]).to eq(relationship.id)
      expect(relationship_hash[:phone]).to eq(relationship.phone)
    end
  end
end

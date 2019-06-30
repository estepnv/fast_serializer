require 'spec_helper'

RSpec.describe "Inherits schema" do
  include_context :fjs_serializer

  let(:serializer) do
    resource_serializer
    class InheritedResourceSerializer < ResourceSerializer
      include FastSerializer::Schema::Mixin

      attribute(:yet_another_email) { |resource| resource.email }
    end

    InheritedResourceSerializer
  end

  subject(:serializable_hash) { serializer_instance.serializable_hash }

  it 'inherits schema' do
    expect(serializable_hash[:yet_another_email]).to eq(resource.email)
    expect(serializable_hash[:email]).to eq(resource.email)
  end
end
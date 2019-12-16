# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Inherits schema' do
  include_context :fjs_serializer

  before do
    class ResourceSerializer
      include FastSerializer::Schema::Mixin
      attribute(:email)
    end

    class InheritedResourceSerializer < ResourceSerializer
      attribute(:yet_another_email, &:email)
    end

    class InheritedResourceSerializer2 < ResourceSerializer
      attribute(:yet_another_email_2, &:email)
    end
  end

  it 'inherits schema' do
    expect(InheritedResourceSerializer.new(resource).serializable_hash[:yet_another_email]).to eq(resource.email)
    expect(InheritedResourceSerializer.new(resource).serializable_hash[:email]).to eq(resource.email)
    expect(InheritedResourceSerializer.new(resource).serializable_hash[:yet_another_email_2]).to be_blank

    expect(InheritedResourceSerializer2.new(resource).serializable_hash[:email]).to eq(resource.email)
    expect(InheritedResourceSerializer2.new(resource).serializable_hash[:yet_another_email]).to be_blank
    expect(InheritedResourceSerializer2.new(resource).serializable_hash[:yet_another_email_2]).to eq(resource.email)
  end
end

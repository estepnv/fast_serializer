# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Inherits schema' do
  include_context :fjs_serializer

  before do
    class ResourceSerializer
      include FastSerializer::Schema::Mixin
      attribute(:email)
      attribute(:foo) { foo }

      def foo
        'foo'
      end
    end

    class InheritedResourceSerializer < ResourceSerializer
      attribute(:yet_another_email, &:email)
    end

    class InheritedResourceSerializer2 < ResourceSerializer
      attribute(:yet_another_email_2, &:email)
    end
  end

  it 'inherits schema' do
    inherited_resource_serializer_h = InheritedResourceSerializer.new(resource).serializable_hash

    expect(inherited_resource_serializer_h[:foo]).to eq('foo')
    expect(inherited_resource_serializer_h[:yet_another_email]).to eq(resource.email)
    expect(inherited_resource_serializer_h[:email]).to eq(resource.email)
    expect(inherited_resource_serializer_h[:yet_another_email_2]).to be_blank

    inherited_resource_serializer_2_h = InheritedResourceSerializer2.new(resource).serializable_hash
    expect(inherited_resource_serializer_2_h[:foo]).to eq('foo')
    expect(inherited_resource_serializer_2_h[:email]).to eq(resource.email)
    expect(inherited_resource_serializer_2_h[:yet_another_email]).to be_blank
    expect(inherited_resource_serializer_2_h[:yet_another_email_2]).to eq(resource.email)
  end
end

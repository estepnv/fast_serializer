# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Inherits schema' do
  include_context :fjs_serializer

  before do
    class ResourceSerializer
      include FastSerializer::Schema::Mixin
      attribute(:email)
      attribute(:foo) { foo }
      attribute(:shared) { params[:shared_context] }

      def foo
        'foo'
      end
    end

    class AssociatedResourceSerializer < ResourceSerializer
      attribute(:id)
      attribute(:shared) { params[:shared_context] }
    end

    class InheritedResourceSerializer < ResourceSerializer
      attribute(:yet_another_email, :email)
    end

    class InheritedResourceSerializer2 < ResourceSerializer
      attribute(:yet_another_email_2, :email)

      has_many :has_many_relationship, serializer: AssociatedResourceSerializer
    end
  end

  it 'inherits schema' do
    inherited_resource_serializer_h = InheritedResourceSerializer.new(resource).serializable_hash

    expect(inherited_resource_serializer_h[:foo]).to eq('foo')
    expect(inherited_resource_serializer_h[:email]).to eq(resource.email)
    expect(inherited_resource_serializer_h[:yet_another_email]).to eq(resource.email)
    expect(inherited_resource_serializer_h[:yet_another_email_2]).to be_blank

    inherited_resource_serializer_2_h = InheritedResourceSerializer2.new(resource).serializable_hash
    expect(inherited_resource_serializer_2_h[:foo]).to eq('foo')
    expect(inherited_resource_serializer_2_h[:email]).to eq(resource.email)
    expect(inherited_resource_serializer_2_h[:yet_another_email]).to be_blank
    expect(inherited_resource_serializer_2_h[:yet_another_email_2]).to eq(resource.email)
    expect(inherited_resource_serializer_h[:shared]).to be_nil
  end

  it 'does not share parameters through the parent class' do
    inherited_resource_serializer_h = InheritedResourceSerializer.new(resource, shared_context: "shared").serializable_hash

    expect(inherited_resource_serializer_h[:shared]).to eq("shared")

    inherited_resource_serializer_2_h = InheritedResourceSerializer2.new(resource).serializable_hash

    expect(inherited_resource_serializer_2_h[:shared]).to be_nil
    expect(inherited_resource_serializer_2_h[:has_many_relationship].first[:shared]).to be_nil
    expect(inherited_resource_serializer_2_h[:has_many_relationship].last[:shared]).to be_nil
  end
end

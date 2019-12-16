# frozen_string_literal: true

shared_context :fjs_serializer do
  let(:resource) { build :resource, :has_one_relation, :has_many_relation }

  let(:resource_serializer) do
    class ResourceSerializer
      include FastSerializer::Schema::Mixin

      attributes :id, :email, :phone

      attribute(:string_id, if: ->(_resource, params) { params[:stringify] }) { |resource, _params| resource.id.to_s }
      attribute(:float_id, unless: ->(_resource, params) { params[:stringify] }) { |resource, _params| resource.id.to_f }
      attribute(:full_name) { |resource, params| params[:only_first_name] ? resource.first_name : "#{resource.first_name} #{resource.last_name}" }

      has_one :has_one_relationship, serializer: ResourceSerializer
      has_many :has_many_relationship, serializer: ResourceSerializer
    end

    ResourceSerializer
  end

  let!(:serializer) { resource_serializer }
  let!(:fjs_serializer) { resource_serializer }

  let(:params) { nil }

  let!(:serializer_instance) { serializer.new(resource, params) }
end

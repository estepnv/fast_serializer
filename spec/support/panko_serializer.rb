# frozen_string_literal: true

shared_context :panko_serializer do
  let(:panko_serializer) do
    require 'panko_serializer'

    class PankoResourceSerializer < Panko::Serializer
      attributes :id, :email, :phone, :float_id, :full_name

      def float_id
        object.id.to_f
      end

      def full_name
        "#{object.first_name} #{object.last_name}"
      end

      has_one :has_one_relationship, serializer: PankoResourceSerializer
      has_many :has_many_relationship, serializer: PankoResourceSerializer
    end

    PankoResourceSerializer
  end
end

# frozen_string_literal: true

module FastSerializer
  module JsonModel
    class Object < Node
      attr_accessor :attributes

      def initialize(args = {})
        super
        @attributes = {}
      end

      # @param attribute [FastSerializer::JsonModel::Node]
      def add_attribute(attribute)
        attributes[attribute.key] = attribute
      end

      # @param resource [Object]
      # @param params [Hash]
      # @param context [Hash]
      # @return [Hash]
      def serialize(resource, params, context)
        return if resource.nil?

        result = {}

        attributes.each do |_, attribute|
          next unless attribute.included?(resource, params, context)

          val = attribute.serialize(resource, params, context)
          result[attribute.key] = val
        end

        result
      end

      # @return [Boolean]
      def included?(*)
        true
      end
    end
  end
end

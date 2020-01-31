# frozen_string_literal: true

module FastSerializer
  module JsonModel
    class Object < Node
      attr_accessor :attributes

      def initialize(args = {})
        super
        @attributes = {}
      end

      def add_attribute(attribute)
        attributes[attribute.key] = attribute
      end

      def serialize(resource, params, context)
        return if resource.nil?

        res = attributes.values.each_with_object({}) do |attribute, res|
          next res unless attribute.included?(resource, params, context)

          val = attribute.serialize(resource, params, context)
          res[attribute.key] = val
        end

        res
      end

      def included?(*)
        true
      end
    end
  end
end

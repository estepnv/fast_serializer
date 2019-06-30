# frozen_string_literal: true

module FastSerializer
  module JsonModel
    class Object < Node
      attr_accessor :attributes

      def initialize(*args)
        super
        @attributes = {}
      end

      def add_attribute(attribute)
        attributes[attribute.key] = attribute
      end

      def serialize(resource, params = {})
        return if resource.nil?

        attributes.values.reduce({}) do |res, attribute|
          next res unless attribute.included?(resource, params)

          val = attribute.serialize(resource, params)
          res[attribute.key] = val if val
          res
        end
      end

      def included?(resource, params = {})
        true
      end

    end
  end
end
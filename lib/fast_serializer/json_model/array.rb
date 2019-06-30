# frozen_string_literal: true

module FastSerializer
  module JsonModel
    class Array < HasManyRelationship

      def serialize(resources, params={})
        return if resources.nil?

        resources.map do |resource|
          serialization_schema.serialize(resource, params)
        end
      end

      def included?(resources, params = {})
        true
      end

    end
  end
end
# frozen_string_literal: true

module FastSerializer
  module JsonModel
    class Array < HasManyRelationship
      def serialize(resources, params = {}, context = nil)
        return if resources.nil?

        resources.map do |resource|
          serialization_schema.serialize(resource, params, context)
        end
      end

      def included?(_resources, _params = {})
        true
      end
    end
  end
end

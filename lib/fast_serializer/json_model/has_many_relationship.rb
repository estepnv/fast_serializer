# frozen_string_literal: true

module FastSerializer
  module JsonModel
    class HasManyRelationship < Relationship
      def serialize(resource, params={})
        collection = resource.public_send(method)
        return if collection.nil?

        collection.map do |relation_resource|
          serialization_schema.serialize(relation_resource, params)
        end
      end
    end
  end
end
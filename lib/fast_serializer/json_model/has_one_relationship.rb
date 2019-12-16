# frozen_string_literal: true

module FastSerializer
  module JsonModel
    class HasOneRelationship < Relationship
      def serialize(resource, params = {}, context = nil)
        serialization_schema.serialize(resource.public_send(method), params, context)
      end
    end
  end
end

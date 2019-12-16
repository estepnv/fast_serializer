# frozen_string_literal: true

module FastSerializer
  module JsonModel
    class HasOneRelationship < Relationship
      def serialize(resource, params = {})
        serialization_schema.serialize(resource.public_send(method), params)
      end
    end
  end
end

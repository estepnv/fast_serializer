# frozen_string_literal: true

module FastSerializer
  module JsonModel
    class HasOneRelationship < Relationship
      # @param resource [Object]
      # @param params [Hash]
      # @return [Hash]
      def serialize(resource, params, _)
        relation = resource.public_send(method)

        if @serializer_klass
          @serializer_klass.new(relation, params).serializable_hash
        elsif @schema
          @schema.serialize_resource(relation, params)
        end
      end
    end
  end
end

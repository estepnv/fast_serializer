# frozen_string_literal: true

module FastSerializer
  module JsonModel
    class HasManyRelationship < Relationship
      # @param resource [Object]
      # @param params [Hash]
      # @return [Array<Hash>]
      def serialize(resource, params, _context)
        collection = resource.public_send(method)
        return if collection.nil?

        if @serializer_klass
          @serializer_klass.new(collection, params).serializable_hash
        elsif @schema
          collection.map { |entry| @schema.serialize_resource(entry, params) }
        end
      end
    end
  end
end

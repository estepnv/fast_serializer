# frozen_string_literal: true

module FastSerializer
  module JsonModel
    class HasManyRelationship < Relationship
      def serialize(resource, params = {}, context = nil)
        collection = resource.public_send(method)
        return if collection.nil?

        if @serializer_klass
          @serializer_klass.new(collection, params).serializable_hash
        elsif @schema
          collection.map { |resource| @schema.serialize_resource(resource, params) }
        end

      end
    end
  end
end

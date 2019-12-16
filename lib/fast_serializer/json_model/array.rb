# frozen_string_literal: true

module FastSerializer
  module JsonModel
    class Array < Relationship
      def serialize(resources, params = {}, context = nil)
        return if resources.nil?

        if @serializer_klass
          @serializer_klass.new(resources, params).serializable_hash
        elsif @schema
          resources.map { |resource| @schema.serialize(resource, params, context) }
        end
      end

      def included?(_resources, _params = {}, context = nil)
        true
      end
    end
  end
end

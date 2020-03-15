# frozen_string_literal: true

module FastSerializer
  module JsonModel
    class Array < Relationship
      # @param resource [Object]
      # @param params [Hash]
      # @param context [Hash]
      # @return [Array]
      def serialize(resources, params, context)
        return if resources.nil?

        if @serializer_klass
          @serializer_klass.new(resources, params).serializable_hash
        elsif @schema
          resources.map { |resource| @schema.serialize(resource, params, context) }
        end
      end

      def included?(*)
        true
      end
    end
  end
end

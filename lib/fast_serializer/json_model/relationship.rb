# frozen_string_literal: true

module FastSerializer
  module JsonModel
    class Relationship < Attribute
      attr_accessor :serialization_schema

      # @param serializer [FastSerializer::Schema::Mixin]
      # @param schema [FastSerializer::Schema]
      def initialize(key, method, serializer = nil, schema = nil, opts = {})
        super(key, method, opts)

        @serializer_klass = serializer
        @schema = schema

        if !@serializer_klass && !@schema
          raise ArgumentError, 'must provide serializer or schema'
        end
      end

      # @param resource [Object]
      # @param params [Hash]
      # @param context [Hash]
      # @return [Boolean]
      def included?(resource, params, context)
        super && include_relation?(params)
      end

      # @param params [Hash]
      # @return [Boolean]
      def include_relation?(params)
        include?(params) && !exclude?(params)
      end

      # @param params [Hash]
      # @return [Boolean]
      def exclude?(params)
        return false if params[:exclude].nil?
        return false if params[:exclude].empty?

        params[:exclude_index].key?(key)
      end

      # @param params [Hash]
      # @return [Boolean]
      def include?(params)
        return true if params[:include].nil?
        return false if params[:include].empty?

        params[:include_index].key?(key)
      end
    end
  end
end

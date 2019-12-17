# frozen_string_literal: true

module FastSerializer
  module JsonModel
    class Relationship < Attribute
      attr_accessor :serialization_schema

      def initialize(key: nil, method: nil, opts: {}, serializer: nil, schema: nil)
        super
        @serializer_klass = serializer
        @schema = schema

        raise ArgumentError, "must provide serializer or schema" if @serializer_klass.nil? && @schema.nil?
      end

      def included?(resource, params, context)
        super(resource, params) && include_relation?(params)
      end

      def include_relation?(params)
        include?(params) && !exclude?(params)
      end

      def exclude?(params)
        return false if params[:exclude].nil?
        return false if params[:exclude].empty?
        params[:exclude_index].key?(key)
      end

      def include?(params)
        return true if params[:include].nil?
        return false if params[:include].empty?
        params[:include_index].has_key?(key)
      end
    end
  end
end

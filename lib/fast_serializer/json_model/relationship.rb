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
        return true if params[:include].nil?

        params[:include].include?(key)
      end
    end
  end
end

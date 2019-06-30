module FastSerializer
  module JsonModel
    class Relationship < Attribute
      attr_accessor :serialization_schema

      def initialize(key: nil, method: nil, opts: {}, serialization_schema:)
        super
        @serialization_schema = serialization_schema
      end

      def included?(resource, params)
        super(resource, params) && include_relation?(params)
      end

      def include_relation?(params)
        return true if params[:include].nil?

        params[:include].include?(key)
      end
    end
  end
end
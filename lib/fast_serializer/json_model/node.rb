# frozen_string_literal: true

module FastSerializer
  module JsonModel
    class Node
      attr_accessor :key, :method

      def initialize(key: nil, method: nil, opts: {}, **_)
        @key = key
        @method = method || key
        @opts = opts || {}
      end

      def serialize(resource, params={})
        raise NotImplementedError
      end

      def included?(resource, params={})
        raise NotImplementedError
      end
    end
  end
end

# frozen_string_literal: true

module FastSerializer
  module JsonModel
    class Node
      attr_accessor :key, :method, :context

      def initialize(key: nil, method: nil, opts: {}, **_)
        @key = key
        @method = method || key
        @opts = opts || {}
      end

      def serialize(_resource, _params = {}, context = nil)
        raise NotImplementedError
      end

      def included?(_resource, _params = {})
        raise NotImplementedError
      end
    end
  end
end

# frozen_string_literal: true

module FastSerializer
  module JsonModel
    class Node
      attr_accessor :key, :method, :context

      # @param key [String]
      # @param method [String]
      # @param opts [Hash]
      def initialize(key: nil, method: nil, opts: {}, **_)
        @key = key&.to_sym
        @method = method || key
        @opts = opts || {}
      end

      # @return [Boolean]
      def injectable?
        false
      end

      def serialize(_resource, _params, _context = nil)
        raise NotImplementedError
      end

      def included?(_resource, _params, _context = nil)
        raise NotImplementedError
      end
    end
  end
end

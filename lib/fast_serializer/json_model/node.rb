# frozen_string_literal: true

module FastSerializer
  module JsonModel
    class Node

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

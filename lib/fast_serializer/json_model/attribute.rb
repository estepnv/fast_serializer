# frozen_string_literal: true

module FastSerializer
  module JsonModel
    class Attribute < Node
      def serialize(resource, params = {})
        if method.is_a?(Proc)
          method.arity.abs == 1 ? method.call(resource) : method.call(resource, params)
        else
          resource.public_send(method)
        end
      end

      def included?(resource, params)
        return true if @opts[:if].nil? && @opts[:unless].nil?

        cond = @opts[:if] || @opts[:unless]

        res = cond.call(resource, params)
        res = !res unless @opts[:unless].nil?

        res
      end
    end
  end
end

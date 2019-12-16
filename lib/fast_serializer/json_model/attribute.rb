# frozen_string_literal: true

module FastSerializer
  module JsonModel
    class Attribute < Node
      def serialize(resource, params = {}, context = nil)
        context ||= self

        if method.is_a?(Proc)

          if method.arity.abs == 1
            context.instance_exec(resource, &method)
          else
            context.instance_exec(resource, params, &method)
          end

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

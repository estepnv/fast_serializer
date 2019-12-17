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

      def included?(resource, params, context = nil)
        return true if @opts[:if].nil? && @opts[:unless].nil?

        cond = @opts[:if] || @opts[:unless]

        res = if cond.is_a?(Proc)
                if cond.arity.abs == 1
                  context.instance_exec(resource, &cond)
                else
                  context.instance_exec(resource, params, &cond)
                end
              else
                context.public_send(cond)
              end

        res = !res unless @opts[:unless].nil?

        res
      end
    end
  end
end

# frozen_string_literal: true

module FastSerializer
  module JsonModel
    class Attribute < Node
      attr_accessor :mixin,
                    :method_name,
                    :method_arity,
                    :cond,
                    :cond_arity,
                    :cond_method_name,
                    :injected

      def initialize(_)
        super
        @mixin = nil
        @method_name = nil
        @injected = false
        @cond_method_name = nil
        @cond = nil
        @cond = @opts[:if] || @opts[:unless] || @cond

        if method.is_a?(Proc)
          @method_name = "__#{key}__"
          @method_arity = method.arity.abs
          @mixin = Module.new
          @mixin.define_method @method_name, &method
        end

        if !cond.nil? && cond.is_a?(Proc)
          @cond_method_name = "__#{key}_cond__"
          @cond_arity = cond.arity.abs
          @mixin ||= Module.new
          @mixin.define_method @cond_method_name, &cond
        end

      end

      def injectable?
        !mixin.nil?
      end

      def inject(context)
        context.include(mixin)
        self.injected = true
      end

      def serialize(resource, params, context)

        val = if injected && !method_name.nil? && !context.nil?
          call_method_on_context(context, method_name, method_arity, resource, params)

        elsif method.is_a?(Proc)
          call_proc_binding_to_context(context, method, method_arity, resource, params)

        else
          resource.public_send(method)
        end

        val.freeze

        val
      end

      def included?(resource, params, context)
        return true if cond.nil?

        res = if injected && !cond_method_name.nil? && !context.nil?
                call_method_on_context(context, cond_method_name, cond_arity, resource, params)

              elsif cond.is_a?(Proc)
                call_proc_binding_to_context(context, cond, cond_arity, resource, params)

              else
                context.public_send(cond)
              end

        res = !res unless @opts[:unless].nil?

        res
      end

      private

      def call_proc_binding_to_context(context, prc, arity, resource, params)
        case arity
        when 1
          context.instance_exec(resource, &prc)
        when 2
          context.instance_exec(resource, params, &prc)
        when 0
          context.instance_exec(&prc)
        end
      end

      def call_method_on_context(context, method_name, arity, resource, params)
        case arity
        when 0
          context.public_send(method_name)
        when 1
          context.public_send(method_name, resource)
        when 2
          context.public_send(method_name, resource, params)
        end
      end
    end
  end
end

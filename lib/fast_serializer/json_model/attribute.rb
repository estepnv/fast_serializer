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

      def initialize(*)
        super

        @mixin = nil
        @method_name = nil
        @injected = false
        @cond_method_name = nil
        @cond = nil
        @cond = @opts[:if] || @opts[:unless] || @cond

        init_with_proc if method.is_a?(Proc)
        init_with_cond if !cond.nil? && cond.is_a?(Proc)
      end

      def injectable?
        !mixin.nil?
      end

      def inject(context)
        context.include(mixin)
        self.injected = true
      end

      # @param resource [Object]
      # @param params [Hash]
      # @param context [Hash]
      # @return [Object]
      def serialize(resource, params, context)
        can_execute_on_mixin = injected && !method_name.nil? && !context.nil?

        val = if can_execute_on_mixin
                call_method_on_context(context, method_name, method_arity, resource, params)
              elsif method.is_a?(Proc)
                call_proc_binding_to_context(context, method, method_arity, resource, params)
              else
                resource.public_send(method)
              end

        val.freeze

        val
      end

      # @param resource [Object]
      # @param params [Hash]
      # @param context [Hash]
      # @return [Boolean]
      def included?(resource, params, context)
        return true if cond.nil?

        can_execute_on_mixin = injected && !cond_method_name.nil? && !context.nil?

        res = if can_execute_on_mixin
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

      def init_with_cond
        @cond_method_name = "__#{key}_cond__"
        @cond_arity = cond.arity.abs
        @mixin ||= Module.new

        if RUBY_VERSION <= '2.5.0'
          @mixin.redefine_method @cond_method_name, &cond
        else
          @mixin.define_method @cond_method_name, &cond
        end
      end

      def init_with_proc
        @method_name = "__#{key}__"
        @method_arity = method.arity.abs
        @mixin = Module.new

        if RUBY_VERSION <= '2.5.0'
          @mixin.redefine_method @method_name, &method
        else
          @mixin.define_method @method_name, &method
        end
      end

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

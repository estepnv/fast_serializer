# frozen_string_literal: true

module FastSerializer
  module JsonModel
    class Attribute < Node
      attr_accessor :key,
                    :method,
                    :context,
                    :opts,
                    :mixin,
                    :method_name,
                    :method_arity,
                    :cond,
                    :cond_arity,
                    :cond_method_name,
                    :injected

      def initialize(key, method, opts = {})
        super()

        @opts = opts || {}
        @injected_methods = Hash.new { |h, method_name| h[method_name] = true }
        @key = key.to_sym
        @method = !method ? key : method

        @mixin = Module.new
        @injected = false

        @method_name = @method && !@method.is_a?(Proc) ? @method : nil
        @method_arity = @method.is_a?(Proc) ? [@method.arity, 0].max : nil
        @cond = @opts[:if] || @opts[:unless]
        @cond_method_name = @cond && !@cond.is_a?(Proc) ? @cond : nil
        @cond_arity = @cond.is_a?(Proc) ? [@cond.arity, 0].max : nil

        init_with_proc if @method.is_a?(Proc)
        init_with_cond if @cond && @cond.is_a?(Proc)
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
        can_execute_on_mixin = !!(injected && method_name && @injected_methods.key?(method_name) && context)

        val = if can_execute_on_mixin
                call_method_on_context(context, method_name, method_arity, resource, params)
              elsif method.is_a?(Proc)
                call_proc_binding_to_context(context, method, method_arity, resource, params)
              else
                resource.public_send(method_name)
              end

        val.freeze

        val
      end

      # @param resource [Object]
      # @param params [Hash]
      # @param context [Hash]
      # @return [Boolean]
      def included?(resource, params, context)
        return true if !cond

        can_execute_on_mixin = !!(injected && cond_method_name && @injected_methods.key?(cond_method_name) && context)

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
        @injected_methods[@cond_method_name]

        if RUBY_VERSION <= '2.5.0'
          @mixin.redefine_method @cond_method_name, &cond
        else
          @mixin.define_method @cond_method_name, &cond
        end
      end

      def init_with_proc
        @method_name = "__#{key}__"
        @injected_methods[@method_name]

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

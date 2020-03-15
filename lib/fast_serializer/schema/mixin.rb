# frozen_string_literal: true

module FastSerializer
  class Schema
    module Mixin
      module ClassMethods
        attr_accessor :__schema__, :__patched__

        def inherited(subclass)
          subclass.__schema__ = __schema__.deep_copy
        end

        def method_missing(method, *args, &block)
          if __schema__.respond_to?(method)
            __schema__.public_send(method, *args, &block)
          else
            super
          end
        end

        def respond_to_missing?(method_name, include_private = false)
          __schema__.respond_to?(method_name) || super
        end

        def __patch_with_attribute_definition
          injectable_attributes = __schema__.serialization_schema.attributes.select { |_key, attribute| attribute.injectable? }
          injectable_attributes.each { |_, attribute| attribute.inject(self) }
          self.__patched__ = true

          __patched__.freeze
        end
      end

      module InstanceMethods
        attr_accessor :resource, :params

        def initialize(resource, params = {})
          self.resource = resource
          self.params   = params || {}
        end

        alias object resource

        def serializable_hash(opts = {})
          Utils.ref_merge(params, opts)
          self.params = params

          unless self.class.__patched__
            self.class.__patch_with_attribute_definition
          end

          self.class.__schema__.serialize_resource(resource, params, self)
        end

        def serialized_json(opts = {})
          self.params = params.merge(opts)
          self.class.__schema__.serialize_resource_to_json(resource, params, self)
        end

        alias as_json serializable_hash
        alias to_json serialized_json
      end

      def self.included(base)
        base.extend ClassMethods
        base.include InstanceMethods
        base.__schema__ = FastSerializer::Schema.new
      end
    end
  end
end

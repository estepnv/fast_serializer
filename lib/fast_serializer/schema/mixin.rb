module FastSerializer
  class Schema
    module Mixin

      module ClassMethods
        attr_accessor :__schema__, :__patched__

        def inherited(subclass)
          subclass.__schema__ = self.__schema__.deep_copy
        end

        def method_missing(method, *args, &block)
          if __schema__.respond_to?(method)
            __schema__.public_send(method, *args, &block)
          else
            super
          end
        end
      end

      module InstanceMethods
        attr_accessor :resource, :params

        def initialize(resource, params = {})
          self.resource = resource
          self.params   = params || {}
        end

        alias_method :object, :resource

        def serializable_hash(opts = {})
          self.params = params.merge(opts)

          if !self.class.__patched__
            injectable_attributes = self.class.__schema__.serialization_schema.attributes.select { |key, attribute| attribute.injectable? }
            injectable_attributes.each { |key, attribute| attribute.inject(self.class) }
            self.class.__patched__ = true
            self.class.__patched__.freeze
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
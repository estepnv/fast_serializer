# frozen_string_literal: true

require 'forwardable'

module FastSerializer

  class Schema
    Context = Struct.new(:resource, :params)

    attr_accessor :_root, :serialization_schema, :params

    def initialize(params = {})
      @root                   = nil
      @serialization_schema   = JsonModel::Object.new
      @params                 = (params || {}).symbolize_keys
      @params[:self]          = self
      @params[:include_index] = {}
      @params[:exclude_index] = {}

      self.include = @params.delete(:include)
      self.exclude = @params.delete(:exclude)
    end

    def include=(list)
      return if !list


      if list.any?
        @params[:include]       = list.map(&:to_sym)
        @params[:include_index] = @params[:include].map { |key| [key, nil] }.to_h
      end
    end

    def exclude=(list)
      return if !list

      if list.any?
        @params[:exclude]       = list.map(&:to_sym)
        @params[:exclude_index] = @params[:exclude].map { |key| [key, nil] }.to_h
      end
    end

    # @param [Array] attribute_names
    def attributes(*attribute_names)
      attribute_names.each do |attribute_name|
        serialization_schema.add_attribute JsonModel::Attribute.new(
          key:    attribute_name,
          method: attribute_name
        )
      end
    end

    # @param [String] attribute_name
    # @param [Hash] opts - attribute options
    # @param [Proc] block - result is used as the attribute value
    def attribute(attribute_name, opts = {}, &block)
      serialization_schema.add_attribute JsonModel::Attribute.new(
        key:    attribute_name,
        method: block,
        opts:   opts
      )
    end

    # @param [String] attribute_name
    # @param [Hash] opts - attribute options
    def has_one(attribute_name, opts = {})
      serialization_schema.add_attribute JsonModel::HasOneRelationship.new(
        key:        opts.delete(:key) || attribute_name,
        method:     opts.delete(:method) || attribute_name,
        opts:       opts,
        schema:     opts.delete(:schema),
        serializer: opts.delete(:serializer)
      )
    end

    alias belongs_to has_one

    # @param [String] attribute_name
    # @param [Hash] opts - attribute options
    def has_many(attribute_name, opts = {})
      serialization_schema.add_attribute JsonModel::HasManyRelationship.new(
        key:        opts.delete(:key) || attribute_name,
        method:     opts.delete(:method) || attribute_name,
        opts:       opts,
        schema:     opts.delete(:schema),
        serializer: opts.delete(:serializer),
      )
    end

    # @param [String] attribute_name
    # @param [Hash] opts - attribute options
    def list(attribute_name, opts = {})
      serialization_schema.add_attribute JsonModel::Array.new(
        key:        attribute_name,
        method:     attribute_name,
        opts:       opts,
        schema:     opts.delete(:schema),
        serializer: opts.delete(:serializer)
      )
    end

    # @param [String] root_key - a key under which serialization result is nested
    def root(root_key)
      self._root = root_key
    end

    def deep_copy
      schema        = FastSerializer::Schema.new
      schema.params = params
      schema._root  = _root

      serialization_schema.attributes.each do |key, attribute|
        schema.serialization_schema.attributes[key] = attribute
      end

      schema
    end

    def serialize_resource(resource, params = {}, context = self)
      _params_dup = self.params.merge(params).symbolize_keys
      meta        = _params_dup.delete(:meta)

      is_collection = resource.respond_to?(:size) && !resource.respond_to?(:each_pair)
      is_collection = params.delete(:is_collection) if params.has_key?(:is_collection)

      root = (_root || _params_dup.delete(:root))

      res = if is_collection

              if !context.is_a?(self.class)
                # need to bind context
                resource.map { |entry| context.class.new(entry, _params_dup).serializable_hash }
              else
                JsonModel::Array.new(schema: serialization_schema).serialize(resource, _params_dup, context)
              end

            else

              serialization_schema.serialize(resource, _params_dup, context)

            end

      res  = { root => res } if root && !root.empty?

      res[:meta] = meta if res.is_a?(Hash) && meta

      res
    end

    def serialize_resource_to_json(resource, params = {}, context = self)
      FastSerializer.config.coder.dump(serialize_resource(resource, params, context))
    end

    module Mixin

      module ClassMethods
        attr_accessor :__schema__

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

        def serializable_hash(opts = {})
          self.params = params.merge(opts)
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

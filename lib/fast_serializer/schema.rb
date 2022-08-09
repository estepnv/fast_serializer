# frozen_string_literal: true

require 'forwardable'

module FastSerializer
  class Schema
    attr_reader :_root, :serialization_schema, :params, :strict

    def initialize(params = {}, root = nil, strict = nil)
      @root                   = root
      @strict                 = strict || FastSerializer.config.strict
      @serialization_schema   = FastSerializer::JsonModel::Object.new
      @params                 = FastSerializer::Utils.symbolize_keys(params || {})
      @params[:self]          = self
      @params[:include_index] = {}
      @params[:exclude_index] = {}

      self.include = @params.delete(:include)
      self.exclude = @params.delete(:exclude)
    end

    def include=(list)
      return unless list
      return if list.empty?

      @params[:include]       = list.map(&:to_sym)
      @params[:include_index] = @params[:include].map { |key| [key, nil] }.to_h
    end

    def exclude=(list)
      return unless list
      return if list.empty?

      @params[:exclude]       = list.map(&:to_sym)
      @params[:exclude_index] = @params[:exclude].map { |key| [key, nil] }.to_h
    end

    # Defines a list of attributes for serialization
    #
    # @param attribute_names [Array<String, Symbol>] a list of attributes to serialize
    # each of these attributes value is fetched calling a corresponding method from a resource instance
    # passed to the serializer
    def attributes(*attribute_names)
      attribute_names.each do |attribute_name|
        serialization_schema.add_attribute(
          JsonModel::Attribute.new(attribute_name, attribute_name)
        )
      end
    end

    # Defines an attribute for serialization
    #
    # @param attribute_name [String, Symbol] an attribute name
    # @param opts [Hash] attribute options
    # @option opts [Proc] :if conditional clause. accepts a proc/lambda which has to return a boolean
    # @option opts [Proc] :unless (see opts:if)
    # @param block [Proc] result is used as the attribute value
    #
    def attribute(attribute_name, opts = {}, &block)
      method = (opts.is_a?(String) || opts.is_a?(Symbol)) ? opts : block
      opts = opts.is_a?(Hash) ? opts : {}

      serialization_schema.add_attribute(
        JsonModel::Attribute.new(attribute_name, method, opts)
      )
    end

    # Defines an attribute for serialization
    #
    # @param attribute_name [String, Symbol] an attribute name
    # @param opts [Hash] attribute options
    # @option opts [Proc] :if conditional clause. accepts a proc/lambda which has to return a boolean
    # @option opts [Proc] :unless (see opts:if)
    # @option opts [FastSerializer::Schema::Mixin, nil] :serializer a serializer class with injected  module or a inherited class
    # @option opts [FastSerializer::Schema] :schema
    #
    def has_one(attribute_name, opts = {})
      serialization_schema.add_attribute(
        JsonModel::HasOneRelationship.new(
          opts.delete(:key) || attribute_name,
          opts.delete(:method) || attribute_name,
          opts.delete(:serializer),
          opts.delete(:schema),
          opts,
        )
      )
    end

    alias belongs_to has_one

    # @param attribute_name [String]
    # @param opts [Hash] attribute options
    def has_many(attribute_name, opts = {})
      serialization_schema.add_attribute(
        JsonModel::HasManyRelationship.new(
          opts.delete(:key) || attribute_name,
          opts.delete(:method) || attribute_name,
          opts.delete(:serializer),
          opts.delete(:schema),
          opts,
        )
      )
    end

    # @param [String] attribute_name
    # @param [Hash] opts - attribute options
    def list(attribute_name, opts = {})
      serialization_schema.add_attribute(
        JsonModel::Array.new(
          attribute_name,
          attribute_name,
          opts.delete(:serializer),
          opts.delete(:schema),
          opts,
        )
      )
    end

    # @param [String] root_key - a key under which serialization result is nested
    def root(root_key)
      @_root = root_key
    end

    def deep_copy
      schema = FastSerializer::Schema.new(params, _root, strict)

      serialization_schema.attributes.each do |key, attribute|
        schema.serialization_schema.attributes[key] = attribute
      end

      schema
    end

    def serialize_resource(resource, params = {}, context = self)
      _params_dup = FastSerializer::Utils.symbolize_keys(self.params)
      Utils.ref_merge(_params_dup, params)
      self.params.delete(:meta)

      meta        = _params_dup.delete(:meta)

      is_collection = if _params_dup.key?(:is_collection)
        _params_dup.delete(:is_collection)
        params.delete(:is_collection)
      else
        resource.respond_to?(:each) && !resource.respond_to?(:each_pair)
      end

      root = (_root || _params_dup.delete(:root))

      res = if is_collection

              if !context.is_a?(self.class)
                # need to bind context
                resource.map { |entry| context.class.new(entry, _params_dup).serializable_hash }
              else
                JsonModel::Array.new(:base, :base, nil, serialization_schema).serialize(resource, _params_dup, context)
              end

            else
              serialization_schema.serialize(resource, _params_dup, context)
            end

      res = { root => res } if root && !root.empty?

      res[:meta] = meta if res.is_a?(Hash) && meta

      res
    end

    def serialize_resource_to_json(resource, params = {}, context = self)
      FastSerializer.config.coder.dump(serialize_resource(resource, params, context))
    end
  end
end

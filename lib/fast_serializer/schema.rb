# frozen_string_literal: true

module FastSerializer
  class Schema
    module InheritanceSupport
      def inherited(subclass)
        subclass._serialization_schema ||= JsonModel::Object.new

        _serialization_schema.attributes.each do |key, attribute|
          subclass._serialization_schema.attributes[key] = attribute
        end
      end
    end

    module SchemaInterface
      attr_accessor :_root, :_serialization_schema

      def init
        @_root ||= nil
        @_serialization_schema ||= JsonModel::Object.new
      end

      # @param [Array] attribute_names
      def attributes(*attribute_names)
        attribute_names.each do |attribute_name|
          _serialization_schema.add_attribute JsonModel::Attribute.new(
            key: attribute_name,
            method: attribute_name
          )
        end
      end

      # @param [String] attribute_name
      # @param [Hash] opts - attribute options
      # @param [Proc] block - result is used as the attribute value
      def attribute(attribute_name, opts = {}, &block)
        _serialization_schema.add_attribute JsonModel::Attribute.new(
          key: attribute_name,
          method: block,
          opts: opts
        )
      end

      # @param [String] attribute_name
      # @param [Hash] opts - attribute options
      def has_one(attribute_name, opts = {})
        unless opts[:serializer]
          raise ArgumentError, 'Serializer is not provided'
        end

        serialization_schema = opts.delete(:serializer)._serialization_schema
        _serialization_schema.add_attribute JsonModel::HasOneRelationship.new(
          key: attribute_name,
          method: attribute_name,
          opts: opts,
          serialization_schema: serialization_schema
        )
      end

      alias belongs_to has_one

      # @param [String] attribute_name
      # @param [Hash] opts - attribute options
      def has_many(attribute_name, opts = {})
        unless opts[:serializer]
          raise ArgumentError, 'Serializer is not provided'
        end

        serialization_schema = opts.delete(:serializer)._serialization_schema
        _serialization_schema.add_attribute JsonModel::HasManyRelationship.new(
          key: attribute_name,
          method: attribute_name,
          opts: opts,
          serialization_schema: serialization_schema
        )
      end

      # @param [String] attribute_name
      # @param [Hash] opts - attribute options
      def list(attribute_name, opts = {})
        unless opts[:serializer]
          raise ArgumentError, 'Serializer is not provided'
        end

        serialization_schema = opts.delete(:serializer)._serialization_schema
        _serialization_schema.add_attribute JsonModel::Array.new(
          key: attribute_name,
          method: attribute_name,
          opts: opts,
          serialization_schema: serialization_schema
        )
      end

      # @param [String] root_key - a key under which serialization result is nested
      def root(root_key)
        self._root = root_key
      end
    end

    module Serialization
      attr_accessor :resource, :params

      def initialize(resource, params = {})
        init if respond_to?(:init)
        @resource = resource
        @params = (params || {}).symbolize_keys
        @params[:self] = self

        if @params[:include]
          if @params[:include].empty?
            @params.delete(:include)
          else
            @params[:include] = @params[:include].map(&:to_sym)
          end
        end
      end

      def serializable_hash
        meta = params.delete(:meta)
        res = schema.serialize(resource, params, self)

        root = (_root || params.delete(:root))

        res = { root => res } if root && !root.empty?

        res[:meta] = meta if res.is_a?(Hash) && meta

        res
      end

      def serialized_json
        FastSerializer.config.coder.dump(serializable_hash)
      end

      private

      def schema
        is_collection = resource.respond_to?(:size) && !resource.respond_to?(:each_pair)

        if is_collection
          JsonModel::Array.new(serialization_schema: _serialization_schema)
        else
          _serialization_schema
        end
      end
    end

    include SchemaInterface
    include Serialization

    module Mixin
      def _serialization_schema
        self.class._serialization_schema
      end

      def _root
        self.class._root
      end

      def self.included(base)
        base.include Serialization
        base.extend InheritanceSupport
        base.extend SchemaInterface

        base.init
      end
    end
  end
end

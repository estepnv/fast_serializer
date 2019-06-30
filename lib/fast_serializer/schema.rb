# frozen_string_literal: true

module FastSerializer

  class Schema

    module InheritanceSupport

      def inherited(subclass)
        subclass.instance_variable_set(:@_serialization_schema, _serialization_schema)
        subclass.instance_variable_set(:@_root, _root)
      end

    end

    module SchemaInterface

      def _serialization_schema
        @_serialization_schema ||= JsonModel::Object.new
      end

      attr_accessor :_root

      def attributes(*attribute_names)
        attribute_names.each do |attribute_name|
          _serialization_schema.add_attribute JsonModel::Attribute.new(
            key: attribute_name,
            method: attribute_name
          )
        end
      end

      def attribute(attribute_name, opts = {}, &block)
        _serialization_schema.add_attribute JsonModel::Attribute.new(
          key: attribute_name,
          method: block,
          opts: opts
        )
      end

      def has_one(attribute_name, opts = {})
        raise ArgumentError, "Serializer is not provided" unless opts[:serializer]

        serialization_schema = opts.delete(:serializer)._serialization_schema
        _serialization_schema.add_attribute JsonModel::HasOneRelationship.new(
          key: attribute_name,
          method: attribute_name,
          opts: opts,
          serialization_schema: serialization_schema
        )
      end

      alias_method :belongs_to, :has_one

      def has_many(attribute_name, opts = {})
        raise ArgumentError, "Serializer is not provided" unless opts[:serializer]

        serialization_schema = opts.delete(:serializer)._serialization_schema
        _serialization_schema.add_attribute JsonModel::HasManyRelationship.new(
          key: attribute_name,
          method: attribute_name,
          opts: opts,
          serialization_schema: serialization_schema
        )
      end

      def list(attribute_name, opts = {})
        raise ArgumentError, "Serializer is not provided" unless opts[:serializer]

        serialization_schema = opts.delete(:serializer)._serialization_schema
        _serialization_schema.add_attribute JsonModel::Array.new(
          key: attribute_name,
          method: attribute_name,
          opts: opts,
          serialization_schema: serialization_schema
        )
      end

      def root(root_key)
        self._root = root_key
      end
    end

    module Serialization
      attr_accessor :resource, :params

      def initialize(resource, params = {})
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
        res = schema.serialize(resource, params)

        root = (_root || params.delete(:root))

        if root && root.size > 0
          res = { root => res }
        end

        if res.is_a?(Hash) && meta
          res[:meta] = meta
        end

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
      end
    end
  end
end
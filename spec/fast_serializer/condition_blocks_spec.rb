# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'condition blocks' do
  include_context :fjs_serializer

  let(:params) { { only_first_name: true } }

  subject(:serializable_hash) { serializer_instance.serializable_hash }

  context 'if clause' do
    let(:params) { { stringify: true } }

    it 'serializes resource' do
      expect(serializable_hash[:string_id]).to eq resource.id.to_s
      expect(serializable_hash.key?(:float_id)).to eq false
    end
  end

  context 'unless clause' do
    let(:params) { { stringify: false } }

    it 'serializes resource' do
      expect(serializable_hash[:float_id]).to eq resource.id.to_f
      expect(serializable_hash.key?(:string_id)).to eq false
    end
  end

  context 'when method passed' do
    let(:serializer) do
      Class.new do
        include FastSerializer::Schema::Mixin

        attribute(:foo) { 'foo' }
        attribute(:bar, if: :bar?) { 'bar' }
        attribute(:baz, unless: :baz?) { 'baz' }

        def bar?
          params[:include_bar]
        end

        def baz?
          params[:exclude_baz]
        end
      end
    end

    it 'serializes resource' do
      hash = serializer.new(resource, include_bar: false, exclude_baz: false).as_json
      expect(hash[:foo]).to eq 'foo'
      expect(hash[:bar]).to eq nil
      expect(hash[:baz]).to eq 'baz'

      hash = serializer.new(resource, include_bar: true, exclude_baz: true).as_json
      expect(hash[:foo]).to eq 'foo'
      expect(hash[:bar]).to eq 'bar'
      expect(hash[:baz]).to eq nil
    end

    context 'when derived' do
      let(:derived_serializer) { Class.new(serializer) }

      it 'serializes resource' do
        hash = derived_serializer.new(resource, include_bar: false, exclude_baz: false).as_json
        expect(hash[:foo]).to eq 'foo'
        expect(hash[:bar]).to eq nil
        expect(hash[:baz]).to eq 'baz'

        hash = derived_serializer.new(resource, include_bar: true, exclude_baz: true).as_json
        expect(hash[:foo]).to eq 'foo'
        expect(hash[:bar]).to eq 'bar'
        expect(hash[:baz]).to eq nil
      end
    end

  end
end

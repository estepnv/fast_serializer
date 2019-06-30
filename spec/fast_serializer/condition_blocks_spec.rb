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
end

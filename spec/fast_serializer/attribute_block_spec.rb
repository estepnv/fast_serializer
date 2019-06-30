require 'spec_helper'

RSpec.describe 'passes params to .attribute block' do
  include_context :fjs_serializer

  let(:params) { { only_first_name: true } }

  subject(:serializable_hash) { serializer_instance.serializable_hash }

  it 'serializes resource' do
    expect(serializable_hash[:full_name]).to eq resource.first_name
  end
end

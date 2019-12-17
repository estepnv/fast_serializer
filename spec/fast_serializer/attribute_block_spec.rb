# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'passes params to .attribute block' do
  include_context :fjs_serializer

  let(:serializer) do
    Class.new do
      include FastSerializer::Schema::Mixin

      attribute(:email) { resource.email.upcase }
      attribute(:full_name) { "#{resource.first_name} #{resource.last_name}" }
      attribute(:full_name_1) { |resource| "#{resource.first_name} #{resource.last_name}" }
      attribute(:full_name_2) { |_, params| "#{params[:first_name]} #{params[:last_name]}" }
    end
  end

  let(:params) { { only_first_name: true } }

  subject(:serializable_hash) { serializer.new(resource, first_name: resource.first_name, last_name: resource.last_name).serializable_hash }

  it 'serializes resource' do
    expect(serializable_hash[:full_name]).to eq "#{resource.first_name} #{resource.last_name}"
    expect(serializable_hash[:full_name_1]).to eq "#{resource.first_name} #{resource.last_name}"
    expect(serializable_hash[:full_name_2]).to eq "#{resource.first_name} #{resource.last_name}"
  end
end

# frozen_string_literal: true

Resource = Struct.new(:id, :email, :first_name, :last_name, :phone, :has_one_relationship, :has_many_relationship) do
  include ActiveModel::Serialization

  def self.model_name
    'resource'
  end
end

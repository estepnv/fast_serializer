shared_context :ams_serializer do
  let(:ams_serializer) do
    class AMSResourceSerializer < ActiveModel::Serializer
      attributes :id, :email, :phone

      attribute(:string_id, if: -> { instance_options[:stringify] }) { object.id.to_s }
      attribute(:float_id, unless: -> { instance_options[:stringify] }) { object.id.to_f }
      attribute(:full_name) { instance_options[:only_first_name] ? object.first_name : "#{object.first_name} #{object.last_name}" }

      has_one :has_one_relationship, serializer: AMSResourceSerializer
      has_many :has_many_relationship, serializer: AMSResourceSerializer
    end

    AMSResourceSerializer
  end
end
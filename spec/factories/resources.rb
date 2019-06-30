FactoryBot.define do
  factory :resource, class: 'Resource' do
    id { Faker::Number.number(10).to_i }
    email { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone { Faker::PhoneNumber.phone_number }

    trait :has_many_relation do
      has_many_relationship { build_list :resource, 2 }
    end

    trait :has_one_relation do
      has_one_relationship { build :resource }
    end

    trait :has_many_relation_with_nested do
      has_many_relationship { build_list :resource, 2, :has_many_relation }
    end

  end
end
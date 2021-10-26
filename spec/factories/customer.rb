FactoryBot.define do
  factory :customer, class: Customer do
    first_name { Faker::Name.unique.name}
    last_name { Faker::Name.unique.name}
  end
end

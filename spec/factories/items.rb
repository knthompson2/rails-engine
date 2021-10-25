FactoryBot.define do
  factory :item, class: Item do
    name { Faker::Name.unique.name}
    description { Faker::Lorem.sentence}
    unit_price { Faker::Number.decimal(l_digits: 2)}
  end
end

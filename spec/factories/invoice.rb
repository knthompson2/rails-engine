FactoryBot.define do
  factory :invoice, class: Invoice do
    status { ['cancelled', 'completed', 'in progress'].sample }
  end
end

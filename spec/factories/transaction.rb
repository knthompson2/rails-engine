FactoryBot.define do
  factory :transaction, class: Transaction do
    result { ["success", "failed"].sample }
  end
end

FactoryBot.define do
  factory :invoice_item, class: InvoiceItem do
    quantity { Faker::Number.within(range: 1..1000) }
    unit_price { Faker::Number.decimal(l_digits: 2) }
  end
end

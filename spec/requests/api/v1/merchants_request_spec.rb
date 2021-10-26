require 'rails_helper'

RSpec.describe "get api/v1/merchants" do
  it 'gets all merchants data' do
    create_list(:merchant, 12)
    per_page = 5
    page = 1

    get "/api/v1/merchants?per_page=#{per_page}&page=#{page}"

    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(merchants).to be_a(Hash)
    expect(merchants).to have_key(:data)
    expect(merchants[:data]).to be_an(Array)
    expect(merchants[:data].first).to have_key(:id)
    expect(merchants[:data].first).to have_key(:type)
    expect(merchants[:data].first).to have_key(:attributes)
    expect(merchants[:data].first[:attributes]).to have_key(:name)
  end

  it 'can find merchant by id' do
    id = create(:merchant).id

    get api_v1_merchant_path(id)

    merchant = JSON.parse(response.body, symbolize_names: true)
    merch = Merchant.find(id)

    expect(response).to be_successful
    expect(merchant).to be_a(Hash)
    expect(merchant).to have_key(:data)
    expect(merchant[:data]).to be_a(Hash)
    expect(merchant[:data]).to have_key(:id)
    expect(merchant[:data]).to have_key(:type)
    expect(merchant[:data]).to have_key(:attributes)
    expect(merchant[:data][:attributes]).to have_key(:name)
    expect(merchant[:data][:attributes][:name]).to eq(merch.name)
  end

  it 'returns all items from one merchant' do
    merchant = create(:merchant)
    create_list(:item, 27, merchant: merchant)

    get api_v1_merchant_items_path(merchant)

    items = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(items).to be_a(Hash)
    expect(items).to have_key(:data)
    expect(items[:data]).to be_a(Array)
    expect(items[:data].first).to have_key(:id)
    expect(items[:data].first).to have_key(:type)
    expect(items[:data].first).to have_key(:attributes)
    expect(items[:data].first[:attributes]).to have_key(:name)
    expect(items[:data].first[:attributes]).to have_key(:description)
    expect(items[:data].first[:attributes]).to have_key(:unit_price)
    expect(items[:data].first[:attributes]).to have_key(:merchant_id)
  end

  it 'finds a merchant by name search' do
    merchant = create(:merchant, name: "Cool Shirts")
    merchant_2 = create(:merchant, name: "Lame Shirts")

    get "/api/v1/merchants/find", params: {name: "cool"}

    expect(response).to be_successful
  end

  it 'returns a quantity of merchants sorted by desc revenue' do
    merchant1 = create(:merchant)
    merchant2 = create(:merchant)
    merchant3 = create(:merchant)

    customer1 = create(:customer)

    item1 = create(:item, merchant_id: merchant1.id)
    item2 = create(:item, merchant_id: merchant1.id)
    item3 = create(:item, merchant_id: merchant2.id)
    item4 = create(:item, merchant_id: merchant2.id)
    item5 = create(:item, merchant_id: merchant3.id)
    item6 = create(:item, merchant_id: merchant3.id)

    invoice1 = create(:invoice, customer_id: customer1.id, merchant_id: merchant1.id)
    invoice2 = create(:invoice, customer_id: customer1.id, merchant_id: merchant2.id)

    invoice_item1 = create(:invoice_item, item_id: item1.id, invoice_id: invoice1.id)
    invoice_item2 = create(:invoice_item, item_id: item2.id, invoice_id: invoice1.id)
    invoice_item3 = create(:invoice_item, item_id: item3.id, invoice_id: invoice2.id)

    transaction1 = create(:transaction, invoice_id: invoice1.id, result: 0)
    transaction2 = create(:transaction, invoice_id: invoice2.id, result: 0)

    get "/api/v1/merchants/most_items", params: { quantity: 2 }
    binding.pry
    expect(response).to be_successful

    merchants = JSON.parse(response.body, symbolize_names: true)
  end
end

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
end

require 'rails_helper'

RSpec.describe "get api/v1/items" do
  it 'gets all items data' do
    merchants = create_list(:merchant, 2)
    create_list(:item, 27, merchant: merchants.first)
    create_list(:item, 27, merchant: merchants.last)

    per_page = 3
    page = 4

    get "/api/v1/items?per_page=#{per_page}&page=#{page}"
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

  it 'can item by id' do
    merchant = create(:merchant)
    id = create(:item, merchant: merchant).id

    get api_v1_item_path(id)

    item = JSON.parse(response.body, symbolize_names: true)
    item_check = Item.find(id)

    expect(response).to be_successful
    expect(item).to be_a(Hash)
    expect(item).to have_key(:data)
    expect(item[:data]).to be_a(Hash)
    expect(item[:data]).to have_key(:id)
    expect(item[:data]).to have_key(:type)
    expect(item[:data]).to have_key(:attributes)
    expect(item[:data][:attributes]).to have_key(:name)
    expect(item[:data][:attributes][:name]).to eq(item_check.name)
  end

  it "can create a new item" do
    merchant = create(:merchant)
    item_params = ({
                    type: 'item',
                    attributes: {
                                  name: "Item Name",
                                  description: "Itemy item item",
                                  unit_price: 10.99,
                                  merchant_id: merchant.id
                      }
                  })
    headers = {"CONTENT_TYPE" => "application/json"}

    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
    item = Item.last

    expect(response).to be_successful
    expect(item.type).to eq(item_params[:type])
    # expect(item.data.name).to eq(item_params[:attributes][:name])

  end

  it "can destroy an item" do
    merchant = create(:merchant)
    item = create(:item, merchant: merchant)

    expect(Item.count).to eq(1)

    delete "/api/v1/items/#{item.id}"

    expect(response).to be_successful
    expect(Item.count).to eq(0)
    expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "can update an existing item" do
    merchant = create(:merchant)
    id = create(:item, merchant: merchant).id
    previous_name = Item.last.description
    item_params = { description: "Itemiest item of all items" }
    headers = {"CONTENT_TYPE" => "application/json"}

    # We include this header to make sure that these params are passed as JSON rather than as plain text
    patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate({item: item_params})
    item = Item.find_by(id: id)

    expect(response).to be_successful
    expect(item.description).to_not eq(previous_name)
    expect(item.description).to eq("Itemiest item of all items")
  end

  it 'returns the merchant for an item' do
    new_merchant = create(:merchant)
    item = create(:item, merchant: new_merchant)

    get api_v1_item_merchant_path(item)

    merchant = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(merchant).to be_a(Hash)
    expect(merchant).to have_key(:data)
    expect(merchant[:data]).to be_a(Hash)
    expect(merchant[:data]).to have_key(:id)
    expect(merchant[:data]).to have_key(:type)
    expect(merchant[:data]).to have_key(:attributes)
    expect(merchant[:data][:attributes]).to have_key(:name)
  end

  it 'will return a quantity of items ranked by desc revenue' do
    merchant1 = create(:merchant)
    customer1 = create(:customer)
    item1 = create(:item, merchant_id: merchant1.id)
    item2 = create(:item, merchant_id: merchant1.id)
    item3 = create(:item, merchant_id: merchant1.id)
    item4 = create(:item, merchant_id: merchant1.id)
    item5 = create(:item, merchant_id: merchant1.id)
    item6 = create(:item, merchant_id: merchant1.id)
    invoice1 = create(:invoice, customer_id: customer1.id, merchant_id: merchant1.id)
    invoice2 = create(:invoice, customer_id: customer1.id, merchant_id: merchant1.id)
    invoice_item1 = create(:invoice_item, item_id: item1.id, invoice_id: invoice1.id, quantity: 10, unit_price: 2.00)
    invoice_item2 = create(:invoice_item, item_id: item2.id, invoice_id: invoice1.id, quantity: 10, unit_price: 5.00)
    invoice_item3 = create(:invoice_item, item_id: item3.id, invoice_id: invoice2.id, quantity: 5, unit_price: 3.00)
    transaction1 = create(:transaction, invoice_id: invoice1.id, result: "success")
    transaction2 = create(:transaction, invoice_id: invoice2.id, result: "success")
    get "/api/v1/revenue/items", params: { quantity: 2 }
    expect(response).to be_successful
    merchant = JSON.parse(response.body, symbolize_names: true)
    expect(merchant).to be_a(Hash)
  end
end

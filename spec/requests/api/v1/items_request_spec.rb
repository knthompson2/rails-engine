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

  it 'can return item by id' do
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

  it 'sad path: can return item by id' do
    fake_item = 44

    get api_v1_item_path(fake_item)

    expect(response).to_not be_successful
    expect(status).to eq(404)
  end

  it "can create a new item" do
    merchant = create(:merchant)
    item_params = {name: "Item Name",
                   description: "Itemy item item",
                   unit_price: 10.99,
                   merchant_id: merchant.id
                  }

    headers = {"CONTENT_TYPE" => "application/json"}

    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
    item = JSON.parse(response.body, symbolize_names: true)
    item_check = Item.last

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

  it "sad path: can create a new item" do
    merchant = create(:merchant)
    item_params = {
                   description: "Itemy item item",
                   unit_price: 10.99,
                   merchant_id: merchant.id
                  }

    headers = {"CONTENT_TYPE" => "application/json"}

    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

    expect(response).to_not be_successful
    expect(status).to eq(400)
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

  it 'sad path: can delete item' do
    fake_item = 44

    delete "/api/v1/items/#{fake_item}"

    expect(response).to_not be_successful
    expect(status).to eq(404)
  end

  it "can update an existing item" do
    merchant = create(:merchant)
    id = create(:item, merchant: merchant).id
    previous_name = Item.last.description
    item_params = { description: "Itemiest item of all items" }
    headers = {"CONTENT_TYPE" => "application/json"}

    patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate({item: item_params})
    item = Item.find_by(id: id)

    expect(response).to be_successful
    expect(item.description).to_not eq(previous_name)
    expect(item.description).to eq("Itemiest item of all items")
  end

  it 'sad path: can update item' do
    fake_item = 44

    patch "/api/v1/items/#{fake_item}"

    expect(response).to_not be_successful
    expect(status).to eq(404)
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

  it 'sad path: returns the merchant for an item' do
    item = 56
    get api_v1_item_merchant_path(item)

    expect(response).to_not be_successful
    expect(status).to eq(404)
  end

  it 'will return a quantity of items ranked by desc revenue' do
    merchant1 = create(:merchant)
    customer1 = create(:customer)
    item1 = create(:item, merchant_id: merchant1.id)
    item2 = create(:item, merchant_id: merchant1.id)
    item3 = create(:item, merchant_id: merchant1.id)
    create(:item, merchant_id: merchant1.id)
    create(:item, merchant_id: merchant1.id)
    create(:item, merchant_id: merchant1.id)
    invoice1 = create(:invoice, customer_id: customer1.id, merchant_id: merchant1.id)
    invoice2 = create(:invoice, customer_id: customer1.id, merchant_id: merchant1.id)
    create(:invoice_item, item_id: item1.id, invoice_id: invoice1.id, quantity: 10, unit_price: 2.00)
    create(:invoice_item, item_id: item2.id, invoice_id: invoice1.id, quantity: 10, unit_price: 5.00)
    create(:invoice_item, item_id: item3.id, invoice_id: invoice2.id, quantity: 5, unit_price: 3.00)
    create(:transaction, invoice_id: invoice1.id, result: "success")
    create(:transaction, invoice_id: invoice2.id, result: "success")
    get "/api/v1/revenue/items", params: { quantity: 2 }
    expect(response).to be_successful
    merchant = JSON.parse(response.body, symbolize_names: true)
    expect(merchant).to be_a(Hash)
  end

  it 'will return a list of items by name search' do
    merchant1 = create(:merchant)
    customer1 = create(:customer)
    item1 = create(:item, merchant_id: merchant1.id)
    item2 = create(:item, merchant_id: merchant1.id)
    item3 = create(:item, merchant_id: merchant1.id)
    create(:item, merchant_id: merchant1.id)
    create(:item, merchant_id: merchant1.id)
    create(:item, merchant_id: merchant1.id)
    invoice1 = create(:invoice, customer_id: customer1.id, merchant_id: merchant1.id)
    invoice2 = create(:invoice, customer_id: customer1.id, merchant_id: merchant1.id)
    create(:invoice_item, item_id: item1.id, invoice_id: invoice1.id, quantity: 10, unit_price: 2.00)
    create(:invoice_item, item_id: item2.id, invoice_id: invoice1.id, quantity: 10, unit_price: 5.00)
    create(:invoice_item, item_id: item3.id, invoice_id: invoice2.id, quantity: 5, unit_price: 3.00)
    create(:transaction, invoice_id: invoice1.id, result: "success")
    create(:transaction, invoice_id: invoice2.id, result: "success")

    get "/api/v1/items/find_all", params: { name: "#{item1.name}"}
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

  it 'will return a list of items by min search' do
    merchant1 = create(:merchant)
    customer1 = create(:customer)
    item1 = create(:item, unit_price: 12.07, merchant_id: merchant1.id)
    item2 = create(:item, merchant_id: merchant1.id)
    item3 = create(:item, merchant_id: merchant1.id)
    create(:item, merchant_id: merchant1.id)
    create(:item, merchant_id: merchant1.id)
    create(:item, merchant_id: merchant1.id)
    invoice1 = create(:invoice, customer_id: customer1.id, merchant_id: merchant1.id)
    invoice2 = create(:invoice, customer_id: customer1.id, merchant_id: merchant1.id)
    create(:invoice_item, item_id: item1.id, invoice_id: invoice1.id, quantity: 10, unit_price: 2.00)
    create(:invoice_item, item_id: item2.id, invoice_id: invoice1.id, quantity: 10, unit_price: 5.00)
    create(:invoice_item, item_id: item3.id, invoice_id: invoice2.id, quantity: 5, unit_price: 3.00)
    create(:transaction, invoice_id: invoice1.id, result: "success")
    create(:transaction, invoice_id: invoice2.id, result: "success")

    get "/api/v1/items/find_all", params: { min: "#{item1.unit_price}"}
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

  it 'will return a list of items by max search' do
    merchant1 = create(:merchant)
    customer1 = create(:customer)
    item1 = create(:item, unit_price: 87.33, merchant_id: merchant1.id)
    item2 = create(:item, merchant_id: merchant1.id)
    item3 = create(:item, merchant_id: merchant1.id)
    create(:item, merchant_id: merchant1.id)
    create(:item, merchant_id: merchant1.id)
    create(:item, merchant_id: merchant1.id)
    invoice1 = create(:invoice, customer_id: customer1.id, merchant_id: merchant1.id)
    invoice2 = create(:invoice, customer_id: customer1.id, merchant_id: merchant1.id)
    create(:invoice_item, item_id: item1.id, invoice_id: invoice1.id, quantity: 10, unit_price: 2.00)
    create(:invoice_item, item_id: item2.id, invoice_id: invoice1.id, quantity: 10, unit_price: 5.00)
    create(:invoice_item, item_id: item3.id, invoice_id: invoice2.id, quantity: 5, unit_price: 3.00)
    create(:transaction, invoice_id: invoice1.id, result: "success")
    create(:transaction, invoice_id: invoice2.id, result: "success")

    get "/api/v1/items/find_all", params: { max: "#{item1.unit_price}"}
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

  it 'will return a list of items by max and min search' do
    merchant1 = create(:merchant)
    customer1 = create(:customer)
    item1 = create(:item, unit_price: 12.57, merchant_id: merchant1.id)
    item2 = create(:item, unit_price: 71.44, merchant_id: merchant1.id)
    item3 = create(:item, merchant_id: merchant1.id)
    create(:item, merchant_id: merchant1.id)
    create(:item, merchant_id: merchant1.id)
    create(:item, merchant_id: merchant1.id)
    invoice1 = create(:invoice, customer_id: customer1.id, merchant_id: merchant1.id)
    invoice2 = create(:invoice, customer_id: customer1.id, merchant_id: merchant1.id)
    create(:invoice_item, item_id: item1.id, invoice_id: invoice1.id, quantity: 10, unit_price: 2.00)
    create(:invoice_item, item_id: item2.id, invoice_id: invoice1.id, quantity: 10, unit_price: 5.00)
    create(:invoice_item, item_id: item3.id, invoice_id: invoice2.id, quantity: 5, unit_price: 3.00)
    create(:transaction, invoice_id: invoice1.id, result: "success")

    get "/api/v1/items/find_all", params: { max: "#{item2.unit_price}", min: "#{item1.unit_price}"}
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

  it 'will error out when name and min or max are both provided' do
    merchant1 = create(:merchant)
    customer1 = create(:customer)
    item1 = create(:item, merchant_id: merchant1.id)
    item2 = create(:item, merchant_id: merchant1.id)
    item3 = create(:item, merchant_id: merchant1.id)
    create(:item, merchant_id: merchant1.id)
    create(:item, merchant_id: merchant1.id)
    create(:item, merchant_id: merchant1.id)
    invoice1 = create(:invoice, customer_id: customer1.id, merchant_id: merchant1.id)
    invoice2 = create(:invoice, customer_id: customer1.id, merchant_id: merchant1.id)
    create(:invoice_item, item_id: item1.id, invoice_id: invoice1.id, quantity: 10, unit_price: 2.00)
    create(:invoice_item, item_id: item2.id, invoice_id: invoice1.id, quantity: 10, unit_price: 5.00)
    create(:invoice_item, item_id: item3.id, invoice_id: invoice2.id, quantity: 5, unit_price: 3.00)
    create(:transaction, invoice_id: invoice1.id, result: "success")
    create(:transaction, invoice_id: invoice2.id, result: "success")

    get "/api/v1/items/find_all", params: { name: "#{item2.name}", min: "#{item1.unit_price}"}
    expect(response).to_not be_successful
    expect(status).to eq(404)
  end

  it 'returns top revenue items, ' do
    merchant1 = create(:merchant)
    customer1 = create(:customer)
    item1 = create(:item, merchant_id: merchant1.id)
    item2 = create(:item, merchant_id: merchant1.id)
    item3 = create(:item, merchant_id: merchant1.id)
    create(:item, merchant_id: merchant1.id)
    create(:item, merchant_id: merchant1.id)
    create(:item, merchant_id: merchant1.id)
    invoice1 = create(:invoice, customer_id: customer1.id, merchant_id: merchant1.id)
    invoice2 = create(:invoice, customer_id: customer1.id, merchant_id: merchant1.id)
    create(:invoice_item, item_id: item1.id, invoice_id: invoice1.id, quantity: 10, unit_price: 2.00)
    create(:invoice_item, item_id: item2.id, invoice_id: invoice1.id, quantity: 10, unit_price: 5.00)
    create(:invoice_item, item_id: item3.id, invoice_id: invoice2.id, quantity: 5, unit_price: 3.00)
    create(:transaction, invoice_id: invoice1.id, result: "success")
    create(:transaction, invoice_id: invoice2.id, result: "success")

    get "/api/v1/revenue/items"
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
    expect(items[:data].first[:attributes]).to have_key(:revenue)
  end

  it 'returns top revenue items' do
    merchant1 = create(:merchant)
    customer1 = create(:customer)
    item1 = create(:item, merchant_id: merchant1.id)
    item2 = create(:item, merchant_id: merchant1.id)
    item3 = create(:item, merchant_id: merchant1.id)
    create(:item, merchant_id: merchant1.id)
    create(:item, merchant_id: merchant1.id)
    create(:item, merchant_id: merchant1.id)
    invoice1 = create(:invoice, customer_id: customer1.id, merchant_id: merchant1.id)
    invoice2 = create(:invoice, customer_id: customer1.id, merchant_id: merchant1.id)
    create(:invoice_item, item_id: item1.id, invoice_id: invoice1.id, quantity: 10, unit_price: 2.00)
    create(:invoice_item, item_id: item2.id, invoice_id: invoice1.id, quantity: 10, unit_price: 5.00)
    create(:invoice_item, item_id: item3.id, invoice_id: invoice2.id, quantity: 5, unit_price: 3.00)
    create(:transaction, invoice_id: invoice1.id, result: "success")
    create(:transaction, invoice_id: invoice2.id, result: "success")

    get "/api/v1/revenue/items", params: { quantity: -5}

    expect(response).to_not be_successful
    expect(status).to eq(400)
  end
end

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

  # it "can create a new item" do
  #   book_params = ({
  #                   title: 'Murder on the Orient Express',
  #                   author: 'Agatha Christie',
  #                   genre: 'mystery',
  #                   summary: 'Filled with suspense.',
  #                   number_sold: 432
  #                 })
  #   headers = {"CONTENT_TYPE" => "application/json"}
  #
  #   # We include this header to make sure that these params are passed as JSON rather than as plain text
  #   post "/api/v1/books", headers: headers, params: JSON.generate(book: book_params)
  #   created_book = Book.last
  #
  #   expect(response).to be_successful
  #   expect(created_book.title).to eq(book_params[:title])
  #   expect(created_book.author).to eq(book_params[:author])
  #   expect(created_book.summary).to eq(book_params[:summary])
  #   expect(created_book.genre).to eq(book_params[:genre])
  #   expect(created_book.number_sold).to eq(book_params[:number_sold])
  # end

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
end

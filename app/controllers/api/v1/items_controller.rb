class Api::V1::ItemsController < ApplicationController
  def index
    items = Item.pagination(page = params[:page].to_i, per_page = params[:per_page].to_i)
    render json: ItemSerializer.new(items)
  end

  def show
    item = Item.find(params[:id])
    render json: ItemSerializer.new(item)
  end
end

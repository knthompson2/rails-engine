class Api::V1::ItemsController < ApplicationController
  def index
    items = Item.pagination(page = params[:page].to_i, per_page = params[:per_page].to_i)
    render json: ItemSerializer.new(items)
  end

  def show
    item = Item.find(params[:id])
    render json: ItemSerializer.new(item)
  end

  def create
    item = Item.create(item_params)
    render json: ItemSerializer.new(item), status: 201
  end

  def update
    item = Item.find_by(id: params[:id])
    if item && item.update(item_params)
      render json: ItemSerializer.new(item)
    else
      render json: {error: "not-found"}, status: 404
    end
  end

  def destroy
    render json: Item.delete(params[:id])
  end

  def find_all
    if params[:name] && !params[:min] && !params[:max]
      items = Item.find_by_name(params[:name])
      render json: ItemSerializer.new(items)
    elsif !params[:name] && (params[:min] || params[:max])
      items = Item.find_by_price(params[:min], params[:max])
      render json: ItemSerializer.new(items)
    else
      render json: {error: "not-found"}, status: 404
    end
  end
  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end

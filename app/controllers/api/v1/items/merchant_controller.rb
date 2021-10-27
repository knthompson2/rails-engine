class Api::V1::Items::MerchantController < ApplicationController
  def show
    if Item.exists?(params[:item_id])
      item = Item.find(params[:item_id])
      render json: MerchantSerializer.new(item.merchant)
    else
      render json: {error: "not-found"}, status: 404
    end
  end
end

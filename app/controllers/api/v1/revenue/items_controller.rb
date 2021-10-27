class Api::V1::Revenue::ItemsController < ApplicationController
  def items_by_revenue
    if !params[:quantity]
      items = Item.top_revenue_items
      render json: RevenueSerializer.item_revenue(items)
    elsif params[:quantity].to_i > 0
      items = Item.top_revenue_items(params[:quantity])
      render json: RevenueSerializer.item_revenue(items)
    else
      render json: { error: "bad-request"}, status: 400
    end
  end
end

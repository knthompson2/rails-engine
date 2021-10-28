class Api::V1::MerchantsController < ApplicationController
  def index
    merchants = Merchant.pagination(page = params[:page].to_i, per_page = params[:per_page].to_i)
    render json: MerchantSerializer.new(merchants)
  end

  def show
    if Merchant.exists?(params[:id])
      merchant = Merchant.find(params[:id])
      render json: MerchantSerializer.new(merchant)
    else
      render json: {error: "not-found"}, status: 404
    end
  end

  def find
    if params[:name] && !params[:name].empty?
      merchant = Merchant.find_merchant_by_name(params[:name])
      binding.pry
        if merchant != []
          render json: MerchantSerializer.new(merchant.first), status: 200
        else
          render json: MerchantSerializer.new(Merchant.new), status: 200
        end
    else
      render json: {error: "bad-request"}, status: 400
    end
  end

  def most_items
    if params[:quantity]
      merchants = Merchant.top_merchants_items(params[:quantity])
      render json: TopMerchantSerializer.new(merchants)
    else
      render json: {error: "bad-request"}, status: 400
    end
  end

  def revenue
    if params[:quantity] && params[:quantity].to_i > 0
      merchants = Merchant.top_merchants_revenue(params[:quantity])
      render json: RevenueSerializer.new(merchants)
    else
      render json: {error: "bad-request"}, status: 400
    end
  end

  def one_revenue
    if Merchant.find_by(id: params[:id])
      merchant = Merchant.revenue_by_merchant(params[:id])
      render json: RevenueSerializer.one_merchant_revenue(merchant)
    else
      render json: {error: "not-found"}, status: 404
    end
  end

end

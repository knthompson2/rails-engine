class Api::V1::MerchantsController < ApplicationController
  def index
    merchants = Merchant.pagination(page = params[:page].to_i, per_page = params[:per_page].to_i)
    render json: MerchantSerializer.new(merchants)
  end

  def show
    merchant = Merchant.find(params[:id])
    render json: MerchantSerializer.new(merchant)
  end

  def find
    if params[:name]
      merchant = Merchant.find_merchant_by_name(params[:name]).first
      render json: MerchantSerializer.new(merchant), status: 200
    else
      render json: {error: "bad-request"}, status: 400
    end
  end

  def most_items
    if params[:quantity]
      merchants = Merchant.top_merchants(params[:quantity])
      render json: TopMerchantSerializer.new(merchants)
    else
      render json: {error: "bad-request"}, status: 400
    end
  end
end

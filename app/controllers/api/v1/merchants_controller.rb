class Api::V1::MerchantsController < ApplicationController
  def index
    merchants = Merchant.pagination(page = params[:page].to_i, per_page = params[:per_page].to_i)
    render json: MerchantSerializer.new(merchants)
  end

  def show
    merchant = Merchant.find(params[:id])
    render json: MerchantSerializer.new(merchant)
  end
end

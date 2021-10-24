class Api::V1::MerchantsController < ApplicationController
  def index
    merchants = Merchant.pagination(page = params[:page].to_i, per_page = params[:per_page].to_i)
    render json: MerchantSerializer.all_merchants(merchants)
  end

  def show
    merchant = Merchant.find(params[:id])
    render json: MerchantSerializer.single_merchant(merchant)
  end
end

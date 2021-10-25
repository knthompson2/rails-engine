class Api::V1::Items::MerchantsController < ApplicationController
  def show
    binding.pry
    merchant = Merchant.find_by(item: params[:merchant_id])
  end
end

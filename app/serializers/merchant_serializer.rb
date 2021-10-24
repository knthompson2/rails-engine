class MerchantSerializer
  def self.all_merchants(merchants)
    {
        "data": merchants.map do |m|
          {
          "id": m.id,
          "type": "merchant",
          "attributes": {
            "name": m.name,
          }
        }
      end
    }
  end

  def self.single_merchant(merchant)
    {
        "data":
          {
            "id": merchant.id.to_s,
            "type": "merchant",
            "attributes": {
              "name": merchant.name,
          }
        }
    }
  end
end

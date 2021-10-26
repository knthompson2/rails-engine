class TopMerchantSerializer
  include JSONAPI::Serializer
  attributes :name, :count
end

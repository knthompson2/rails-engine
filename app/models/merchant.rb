class Merchant < ApplicationRecord
  extend Pagination

  validates_presence_of :name
  has_many :items, dependent: :destroy
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items

  def self.find_merchant_by_name(name)
    where("name ILIKE ?", "%#{name}%")
    .order("name")
    .first
  end

  def self.top_merchants_items(limit = 5)
    joins(items: {invoice_items: {invoice: :transactions}})
    .select("merchants.*, SUM(invoice_items.quantity) AS count")
    .where("transactions.result = ?", "success")
    .group("merchants.id")
    .order('count desc')
    .limit(limit)
  end

  def self.top_merchants_revenue(quantity)
    joins(items: {invoice_items: {invoice: :transactions}})
    .select("merchants.*, SUM(invoice_items.unit_price * invoice_items.quantity) AS revenue")
    .where("transactions.result = ?", "success")
    .group("merchants.id")
    .order('revenue desc')
    .limit(quantity)
  end

  def self.revenue_by_merchant(merchant_id)
    joins(items: {invoice_items: {invoice: :transactions}})
    .select("merchants.*, SUM(invoice_items.unit_price * invoice_items.quantity) AS revenue")
    .where("transactions.result = ? AND merchants.id = ?", "success", merchant_id)
    .group("merchants.id")
    .first
  end
end

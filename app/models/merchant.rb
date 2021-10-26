class Merchant < ApplicationRecord
  validates_presence_of :name
  has_many :items, dependent: :destroy
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items


  def self.pagination(page = 1, per_page = 20)
    page = 1 if page < 1
    per_page = 20 if per_page < 1
    limit(per_page).offset((page - 1) * per_page)
  end

  def self.find_merchant_by_name(name)
    where("name ILIKE ?", "%#{name}%")
    .order("lower(name)")
  end

  def self.top_merchants(limit = 5)
    joins(items: {invoice_items: {invoice: :transactions}})
    .select("merchants.*, SUM(invoice_items.quantity) AS count")
    .where("transactions.result = ?", "success")
    .group("merchants.id")
    .order('count desc')
    .limit(limit)
  end
end

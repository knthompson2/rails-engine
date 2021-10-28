class Item < ApplicationRecord
  extend Pagination
  
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :unit_price
  validates_presence_of :merchant_id
  belongs_to :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items

  def self.find_by_name(name)
    where("name ILIKE ?", "%#{name}%")
    .order("lower(name)")
  end

  def self.find_by_price(min, max)
    if max && !min
      where('unit_price < ?', max)
    elsif min && !max
      where('unit_price > ?', min)
    else
      where('unit_price < ? AND unit_price > ?', max, min)
    end
  end

  def self.top_revenue_items(quantity = 10)
    joins(invoice_items: {invoice: :transactions})
    .select("items.*, SUM(invoice_items.unit_price * invoice_items.quantity) AS revenue")
    .where("transactions.result = ?", "success")
    .group("items.id")
    .order("revenue desc")
    .limit(quantity)
  end
end

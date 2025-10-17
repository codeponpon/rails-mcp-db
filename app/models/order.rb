class Order < ApplicationRecord
  self.primary_key = "order_no"
  self.table_name = "order"

  # Associations
  belongs_to :account, foreign_key: "member_id", primary_key: "member_id"

  # Validations
  validates :order_no, presence: true
  validates :member_id, presence: true, length: { maximum: 10 }
  validates :order_date, presence: true
  validates :order_amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true, length: { is: 3 }
  validates :order_status, presence: true, length: { maximum: 50 }
  validates :store_id, presence: true, length: { maximum: 3 }
  validates :axtra_omni_order_id, presence: true, length: { maximum: 50 }

  # Scopes
  scope :by_status, ->(status) { where(order_status: status) }
  scope :by_member, ->(member_id) { where(member_id: member_id) }
  scope :by_currency, ->(curr) { where(currency: curr) }
  scope :by_store, ->(store_id) { where(store_id: store_id) }
  scope :pending, -> { where(order_status: "pending") }
  scope :confirmed, -> { where(order_status: "confirmed") }
  scope :processing, -> { where(order_status: "processing") }
  scope :shipped, -> { where(order_status: "shipped") }
  scope :delivered, -> { where(order_status: "delivered") }
  scope :cancelled, -> { where(order_status: "cancelled") }
  scope :recent, ->(days = 30) { where("order_date >= ?", days.days.ago) }
  scope :by_date_range, ->(start_date, end_date) { where(order_date: start_date..end_date) }

  # Methods
  def is_pending?
    order_status == "pending"
  end

  def is_confirmed?
    order_status == "confirmed"
  end

  def is_processing?
    order_status == "processing"
  end

  def is_shipped?
    order_status == "shipped"
  end

  def is_delivered?
    order_status == "delivered"
  end

  def is_cancelled?
    order_status == "cancelled"
  end

  def is_active?
    !is_cancelled?
  end

  def status_description
    case order_status
    when "pending" then "Pending Confirmation"
    when "confirmed" then "Confirmed"
    when "processing" then "Processing"
    when "shipped" then "Shipped"
    when "delivered" then "Delivered"
    when "cancelled" then "Cancelled"
    else order_status.humanize
    end
  end

  def status_color
    case order_status
    when "pending" then "warning"
    when "confirmed" then "info"
    when "processing" then "primary"
    when "shipped" then "success"
    when "delivered" then "success"
    when "cancelled" then "danger"
    else "secondary"
    end
  end

  def can_be_cancelled?
    [ "pending", "confirmed" ].include?(order_status)
  end

  def can_be_confirmed?
    order_status == "pending"
  end

  def can_be_processed?
    order_status == "confirmed"
  end

  def can_be_shipped?
    order_status == "processing"
  end

  def can_be_delivered?
    order_status == "shipped"
  end

  def days_since_order
    (Date.current - order_date.to_date).to_i
  end

  def is_old_order?(days = 30)
    days_since_order > days
  end

  def order_identifier
    "#{order_no} (#{axtra_omni_order_id})"
  end

  def progress_percentage
    case order_status
    when "pending" then 10
    when "confirmed" then 25
    when "processing" then 50
    when "shipped" then 75
    when "delivered" then 100
    when "cancelled" then 0
    else 0
    end
  end

  def next_status
    case order_status
    when "pending" then "confirmed"
    when "confirmed" then "processing"
    when "processing" then "shipped"
    when "shipped" then "delivered"
    else nil
    end
  end

  def can_progress?
    next_status.present?
  end
end

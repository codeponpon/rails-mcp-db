class Account < ApplicationRecord
  self.primary_key = "member_id"
  self.table_name = "account"

  # Associations
  belongs_to :account_credit, foreign_key: "account_credit_id"
  has_many :account_addresses, foreign_key: "member_id", dependent: :destroy
  has_many :account_billing_note_attachments, foreign_key: "member_id", dependent: :destroy
  has_many :account_contacts, foreign_key: "member_id", dependent: :destroy
  has_many :account_guarantees, foreign_key: "member_id", dependent: :destroy
  has_many :account_stores, foreign_key: "member_id", dependent: :destroy
  has_one :account_term, foreign_key: "member_id", dependent: :destroy
  has_many :advance_receipts, foreign_key: "member_id", dependent: :destroy
  has_many :billing_conditions, foreign_key: "member_id", dependent: :destroy
  has_many :billing_notes, foreign_key: "member_id", dependent: :destroy
  has_many :cheque_payments, foreign_key: "member_id", dependent: :destroy
  has_many :credit_notes, foreign_key: "member_id", dependent: :destroy
  has_many :invoices, foreign_key: "member_id", dependent: :destroy
  has_many :matching_logs, foreign_key: "member_id", dependent: :destroy
  has_many :orders, foreign_key: "member_id", dependent: :destroy
  has_many :payment_conditions, foreign_key: "member_id", dependent: :destroy
  has_many :payment_receipts, foreign_key: "member_id", dependent: :destroy
  has_many :transaction_logs, foreign_key: "member_id", dependent: :destroy

  # Validations
  validates :member_id, presence: true, length: { maximum: 10 }
  validates :customer_type, presence: true, length: { maximum: 50 }
  validates :member_name, presence: true, length: { maximum: 255 }
  validates :tax_id, presence: true, length: { maximum: 20 }
  validates :tax_branch, presence: true, length: { maximum: 20 }
  validates :vat_type, presence: true, length: { maximum: 20 }
  validates :order_status, presence: true, length: { maximum: 20 }
  validates :cv_status, presence: true, length: { maximum: 20 }
  validates :payment_location_type, presence: true, length: { maximum: 50 }
  validates :sales_executive_employee_id, presence: true, length: { maximum: 36 }
  validates :sales_executive_full_name, presence: true, length: { maximum: 255 }
  validates :sales_executive_area_zone, presence: true, length: { maximum: 255 }
  validates :credit_controller_employee_id, presence: true, length: { maximum: 36 }
  validates :credit_controller_full_name, presence: true, length: { maximum: 255 }
  validates :class_price_price_tier, presence: true, length: { maximum: 255 }
  validates :sub_business_type_code, presence: true, length: { maximum: 255 }

  # Scopes
  scope :active, -> { where.not(order_status: "cancelled") }
  scope :overdue, -> { where(is_overdue: true) }
  scope :over_limit, -> { where(is_over_limit: true) }
  scope :by_customer_type, ->(type) { where(customer_type: type) }
  scope :by_business_type, ->(type) { where(business_type: type) }

  # Methods
  def full_name
    member_name
  end

  def is_active?
    order_status != "cancelled"
  end

  def has_overdue?
    is_overdue
  end

  def is_over_limit?
    is_over_limit
  end

  def billing_channel_email?
    billing_channel_email.present?
  end

  def billing_channel_line?
    billing_channel_line_id.present?
  end

  def billing_channel_messenger?
    billing_channel_is_messenger_used
  end
end

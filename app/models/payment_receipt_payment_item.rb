class PaymentReceiptPaymentItem < ApplicationRecord
  self.table_name = "payment_receipt_payment_item"

  # Associations
  belongs_to :payment_receipt, foreign_key: "receipt_no", primary_key: "receipt_no"

  # Validations
  validates :receipt_no, presence: true, length: { maximum: 36 }
  validates :payment_type, presence: true, length: { maximum: 50 }
  validates :payment_amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true, length: { is: 3 }

  # Scopes
  scope :by_payment_type, ->(type) { where(payment_type: type) }
  scope :by_currency, ->(curr) { where(currency: curr) }
  scope :active, -> { where(canceled_date: nil) }
  scope :cancelled, -> { where.not(canceled_date: nil) }

  # Methods
  def is_active?
    canceled_date.nil?
  end

  def is_cancelled?
    canceled_date.present?
  end

  def payment_type_description
    case payment_type
    when "cash" then "Cash Payment"
    when "cheque" then "Cheque Payment"
    when "transfer" then "Bank Transfer"
    when "credit_card" then "Credit Card"
    when "debit_card" then "Debit Card"
    else payment_type.humanize
    end
  end

  def has_source_id?
    payment_source_id.present?
  end

  def can_be_cancelled?
    canceled_date.nil?
  end
end

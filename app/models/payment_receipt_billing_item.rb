class PaymentReceiptBillingItem < ApplicationRecord
  self.table_name = "payment_receipt_billing_item"
  self.primary_key = [ "receipt_no", "document_no" ]

  # Associations
  belongs_to :payment_receipt, foreign_key: "receipt_no", primary_key: "receipt_no"

  # Validations
  validates :receipt_no, presence: true, length: { maximum: 36 }
  validates :document_no, presence: true, length: { maximum: 36 }
  validates :document_type, presence: true, length: { maximum: 50 }
  validates :remaining_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :payment_amount, numericality: { greater_than: 0 }, allow_nil: true
  validates :currency, presence: true, length: { is: 3 }

  # Scopes
  scope :by_document_type, ->(type) { where(document_type: type) }
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

  def document_identifier
    "#{document_type} - #{document_no}"
  end

  def has_payment_amount?
    payment_amount.present? && payment_amount > 0
  end

  def payment_percentage
    return 0 unless has_payment_amount? && remaining_amount > 0
    (payment_amount / remaining_amount * 100).round(2)
  end

  def can_be_cancelled?
    canceled_date.nil?
  end
end

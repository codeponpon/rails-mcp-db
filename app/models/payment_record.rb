class PaymentRecord < ApplicationRecord
  self.table_name = "payment_record"

  # Validations
  validates :credit_sale_reference, presence: true, length: { maximum: 64 }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_type, presence: true, length: { maximum: 50 }
  validates :status, presence: true, length: { maximum: 20 }
  validates :source_type, presence: true, length: { maximum: 50 }
  validates :source_id, presence: true, length: { maximum: 50 }
  validates :reference_1, presence: true, length: { maximum: 64 }
  validates :reference_2, presence: true, length: { maximum: 64 }

  # Scopes
  scope :by_status, ->(status) { where(status: status) }
  scope :by_payment_type, ->(type) { where(payment_type: type) }
  scope :by_source_type, ->(type) { where(source_type: type) }
  scope :successful, -> { where(status: "success") }
  scope :failed, -> { where(status: "failed") }
  scope :pending, -> { where(status: "pending") }

  # Methods
  def is_successful?
    status == "success"
  end

  def is_failed?
    status == "failed"
  end

  def is_pending?
    status == "pending"
  end

  def has_qr_code?
    qr_code.present?
  end

  def has_bar_code?
    bar_code.present?
  end

  def payment_type_description
    case payment_type
    when "credit_card" then "Credit Card Payment"
    when "debit_card" then "Debit Card Payment"
    when "bank_transfer" then "Bank Transfer"
    when "wallet" then "Digital Wallet"
    when "cash" then "Cash Payment"
    else payment_type.humanize
    end
  end

  def source_description
    "#{source_type.humanize} - #{source_id}"
  end

  def reference_description
    "#{reference_1} / #{reference_2}"
  end

  def can_be_processed?
    status == "pending"
  end

  def can_be_reversed?
    status == "success"
  end
end

class PaymentReceipt < ApplicationRecord
  self.primary_key = "receipt_no"
  self.table_name = "payment_receipt"

  # Associations
  belongs_to :account, foreign_key: "member_id", primary_key: "member_id"
  has_many :payment_receipt_billing_items, foreign_key: "receipt_no", dependent: :destroy
  has_many :payment_receipt_payment_items, foreign_key: "receipt_no", dependent: :destroy
  has_many :advance_receipts, foreign_key: "receipt_no", dependent: :destroy

  # Validations
  validates :receipt_no, presence: true, length: { maximum: 36 }
  validates :member_id, presence: true, length: { maximum: 10 }
  validates :channel, presence: true, length: { maximum: 50 }
  validates :store_id, presence: true, length: { maximum: 3 }
  validates :doc_issue_unit, presence: true, length: { maximum: 50 }
  validates :overpayment_amount, numericality: { greater_than_or_equal_to: 0 }

  # Scopes
  scope :by_channel, ->(channel) { where(channel: channel) }
  scope :by_member, ->(member_id) { where(member_id: member_id) }
  scope :by_store, ->(store_id) { where(store_id: store_id) }
  scope :printed, -> { where.not(printed_date: nil) }
  scope :cancelled, -> { where.not(canceled_date: nil) }
  scope :active, -> { where(canceled_date: nil) }
  scope :with_overpayment, -> { where("overpayment_amount > 0") }

  # Methods
  def is_printed?
    printed_date.present?
  end

  def is_cancelled?
    canceled_date.present?
  end

  def is_active?
    canceled_date.nil?
  end

  def has_overpayment?
    overpayment_amount > 0
  end

  def total_payment_amount
    payment_receipt_payment_items.sum(:payment_amount)
  end

  def total_billing_amount
    payment_receipt_billing_items.sum(:payment_amount)
  end

  def net_amount
    total_payment_amount - total_billing_amount
  end

  def payment_channels
    payment_receipt_payment_items.pluck(:payment_type).uniq
  end

  def billing_documents
    payment_receipt_billing_items.includes(:billing_note)
  end

  def can_be_cancelled?
    canceled_date.nil?
  end

  def can_be_printed?
    !is_printed? && is_active?
  end

  def overpayment_action_description
    case overpayment_action
    when "refund" then "Refund to customer"
    when "credit" then "Apply as credit"
    when "advance" then "Apply as advance payment"
    else "No action specified"
    end
  end
end

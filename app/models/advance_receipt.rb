class AdvanceReceipt < ApplicationRecord
  self.primary_key = "advance_receipt_no"
  self.table_name = "advance_receipt"

  # Associations
  belongs_to :account, foreign_key: "member_id", primary_key: "member_id"
  belongs_to :payment_receipt, foreign_key: "receipt_no", primary_key: "receipt_no"

  # Validations
  validates :advance_receipt_no, presence: true, length: { maximum: 36 }
  validates :member_id, presence: true, length: { maximum: 10 }
  validates :receipt_no, presence: true, length: { maximum: 36 }
  validates :currency, presence: true, length: { is: 3 }
  validates :advance_receipt_amount, presence: true, numericality: { greater_than: 0 }
  validates :advance_receipt_date, presence: true
  validates :channel, presence: true, length: { maximum: 50 }
  validates :remaining_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Scopes
  scope :by_member, ->(member_id) { where(member_id: member_id) }
  scope :by_channel, ->(channel) { where(channel: channel) }
  scope :by_currency, ->(curr) { where(currency: curr) }
  scope :attached, -> { where.not(attached_date: nil) }
  scope :cancelled, -> { where.not(canceled_date: nil) }
  scope :active, -> { where(canceled_date: nil) }
  scope :with_remaining_amount, -> { where("remaining_amount > 0") }
  scope :fully_used, -> { where(remaining_amount: 0) }

  # Methods
  def is_attached?
    attached_date.present?
  end

  def is_cancelled?
    canceled_date.present?
  end

  def is_active?
    canceled_date.nil?
  end

  def has_remaining_amount?
    remaining_amount > 0
  end

  def is_fully_used?
    remaining_amount == 0
  end

  def used_amount
    advance_receipt_amount - remaining_amount
  end

  def usage_percentage
    return 0 if advance_receipt_amount.zero?
    (used_amount / advance_receipt_amount * 100).round(2)
  end

  def can_be_attached?
    !is_attached? && is_active?
  end

  def can_be_cancelled?
    !is_cancelled? && is_active?
  end

  def channel_description
    case channel
    when "online" then "Online Payment"
    when "counter" then "Counter Payment"
    when "bank_transfer" then "Bank Transfer"
    when "cheque" then "Cheque Payment"
    else channel.humanize
    end
  end

  def days_since_receipt
    (Date.current - advance_receipt_date.to_date).to_i
  end

  def is_old?(days = 30)
    days_since_receipt > days
  end
end

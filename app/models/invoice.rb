class Invoice < ApplicationRecord
  self.primary_key = "invoice_no"
  self.table_name = "invoice"

  # Associations
  belongs_to :account, foreign_key: "member_id", primary_key: "member_id"
  has_many :credit_notes, foreign_key: "invoice_no", dependent: :restrict
  belongs_to :original_invoice, class_name: "Invoice", foreign_key: "original_invoice_no", primary_key: "invoice_no", optional: true
  has_many :replaced_invoices, class_name: "Invoice", foreign_key: "original_invoice_no", primary_key: "invoice_no"

  # Validations
  validates :invoice_no, presence: true
  validates :member_id, presence: true, length: { maximum: 10 }
  validates :order_no, presence: true, length: { maximum: 36 }
  validates :invoice_date, presence: true
  validates :invoice_amount, presence: true, numericality: { greater_than: 0 }
  validates :remaining_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true, length: { is: 3 }
  validates :due_date, presence: true
  validates :status, presence: true, length: { maximum: 20 }
  validates :seller_user_id, presence: true, length: { maximum: 50 }
  validates :collector_user_id, presence: true, length: { maximum: 50 }
  validates :store_id, presence: true, length: { maximum: 3 }

  # Scopes
  scope :by_status, ->(status) { where(status: status) }
  scope :by_member, ->(member_id) { where(member_id: member_id) }
  scope :by_currency, ->(curr) { where(currency: curr) }
  scope :by_store, ->(store_id) { where(store_id: store_id) }
  scope :overdue, -> { where("due_date < ?", Time.current) }
  scope :due_soon, ->(days = 7) { where("due_date BETWEEN ? AND ?", Time.current, days.days.from_now) }
  scope :paid, -> { where(status: "paid") }
  scope :unpaid, -> { where.not(status: "paid") }
  scope :original, -> { where(original_invoice_no: nil) }
  scope :replacement, -> { where.not(original_invoice_no: nil) }

  # Methods
  def is_overdue?
    due_date < Time.current && status != "paid"
  end

  def is_due_soon?(days = 7)
    due_date.between?(Time.current, days.days.from_now) && status != "paid"
  end

  def is_paid?
    status == "paid"
  end

  def is_unpaid?
    status != "paid"
  end

  def is_original?
    original_invoice_no.nil?
  end

  def is_replacement?
    original_invoice_no.present?
  end

  def days_until_due
    (due_date.to_date - Date.current).to_i
  end

  def days_overdue
    return 0 unless is_overdue?
    (Date.current - due_date.to_date).to_i
  end

  def status_color
    case status
    when "draft" then "secondary"
    when "sent" then "info"
    when "paid" then "success"
    when "overdue" then "danger"
    when "cancelled" then "warning"
    else "secondary"
    end
  end

  def paid_amount
    invoice_amount - remaining_amount
  end

  def payment_percentage
    return 0 if invoice_amount.zero?
    (paid_amount / invoice_amount * 100).round(2)
  end

  def has_credit_notes?
    credit_notes.exists?
  end

  def total_credit_note_amount
    credit_notes.sum(:credit_note_amount)
  end

  def net_amount_after_credits
    invoice_amount - total_credit_note_amount
  end

  def can_be_replaced?
    is_original? && status != "cancelled"
  end

  def can_be_cancelled?
    status == "draft" || status == "sent"
  end

  def replacement_chain
    return [ self ] if is_original?

    chain = []
    current = self
    while current.original_invoice.present?
      current = current.original_invoice
      chain.unshift(current)
    end
    chain << self
    chain
  end
end

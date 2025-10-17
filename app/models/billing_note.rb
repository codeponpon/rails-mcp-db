class BillingNote < ApplicationRecord
  self.primary_key = "billing_note_no"
  self.table_name = "billing_note"

  # Associations
  belongs_to :account, foreign_key: "member_id", primary_key: "member_id"
  has_many :billing_note_items, foreign_key: "billing_note_no", dependent: :destroy

  # Validations
  validates :billing_note_no, presence: true, length: { maximum: 36 }
  validates :member_id, presence: true, length: { maximum: 10 }
  validates :billing_note_date, presence: true
  validates :due_date, presence: true
  validates :status, presence: true, length: { maximum: 20 }
  validates :currency, presence: true, length: { is: 3 }
  validates :grand_total_amount, presence: true, numericality: { greater_than: 0 }

  # Scopes
  scope :by_status, ->(status) { where(status: status) }
  scope :by_currency, ->(curr) { where(currency: curr) }
  scope :by_member, ->(member_id) { where(member_id: member_id) }
  scope :overdue, -> { where("due_date < ?", Time.current) }
  scope :due_soon, ->(days = 7) { where("due_date BETWEEN ? AND ?", Time.current, days.days.from_now) }
  scope :printed, -> { where.not(printed_date: nil) }
  scope :cancelled, -> { where.not(canceled_date: nil) }
  scope :active, -> { where(canceled_date: nil) }

  # Methods
  def is_overdue?
    due_date < Time.current && status != "paid"
  end

  def is_due_soon?(days = 7)
    due_date.between?(Time.current, days.days.from_now) && status != "paid"
  end

  def is_printed?
    printed_date.present?
  end

  def is_cancelled?
    canceled_date.present?
  end

  def is_active?
    canceled_date.nil?
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

  def total_items
    billing_note_items.count
  end

  def can_be_cancelled?
    status == "draft" || status == "sent"
  end

  def can_be_printed?
    status == "draft" && !is_printed?
  end
end

class ChequePayment < ApplicationRecord
  self.table_name = "cheque_payment"

  # Associations
  belongs_to :account, foreign_key: "member_id", primary_key: "member_id"

  # Validations
  validates :member_id, presence: true, length: { maximum: 10 }
  validates :cheque_no, presence: true, length: { maximum: 36 }
  validates :cheque_status, presence: true, length: { maximum: 50 }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true, length: { is: 3 }
  validates :issue_bank, presence: true, length: { maximum: 100 }
  validates :issue_bank_branch, presence: true, length: { maximum: 100 }
  validates :issue_date, presence: true
  validates :deposit_bank, presence: true, length: { maximum: 100 }

  # Scopes
  scope :by_member, ->(member_id) { where(member_id: member_id) }
  scope :by_status, ->(status) { where(cheque_status: status) }
  scope :by_currency, ->(curr) { where(currency: curr) }
  scope :bangkok, -> { where(is_bangkok: true) }
  scope :non_bangkok, -> { where(is_bangkok: false) }
  scope :pay_in, -> { where(is_pay_in: true) }
  scope :pay_out, -> { where(is_pay_in: false) }
  scope :cancelled, -> { where.not(canceled_date: nil) }
  scope :active, -> { where(canceled_date: nil) }

  # Methods
  def is_cancelled?
    canceled_date.present?
  end

  def is_active?
    canceled_date.nil?
  end

  def is_bangkok_cheque?
    is_bangkok
  end

  def is_pay_in_cheque?
    is_pay_in
  end

  def is_pay_out_cheque?
    !is_pay_in
  end

  def bank_description
    "#{issue_bank} - #{issue_bank_branch}"
  end

  def deposit_bank_description
    deposit_bank
  end

  def status_description
    case cheque_status
    when "pending" then "Pending Clearance"
    when "cleared" then "Cleared"
    when "bounced" then "Bounced"
    when "cancelled" then "Cancelled"
    when "returned" then "Returned"
    else cheque_status.humanize
    end
  end

  def status_color
    case cheque_status
    when "pending" then "warning"
    when "cleared" then "success"
    when "bounced" then "danger"
    when "cancelled" then "secondary"
    when "returned" then "info"
    else "secondary"
    end
  end

  def can_be_cancelled?
    cheque_status == "pending" && is_active?
  end

  def can_be_cleared?
    cheque_status == "pending" && is_active?
  end

  def days_since_issue
    (Date.current - issue_date.to_date).to_i
  end

  def is_old_cheque?(days = 30)
    days_since_issue > days
  end

  def clearance_time
    return nil unless cheque_status == "cleared"
    # This would need to be calculated based on when it was cleared
    # For now, return days since issue
    days_since_issue
  end
end

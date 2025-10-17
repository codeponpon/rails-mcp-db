class AccountCredit < ApplicationRecord
  self.table_name = "account_credit"

  # Associations
  has_many :accounts, foreign_key: "account_credit_id", dependent: :restrict
  has_many :transaction_logs, foreign_key: "account_credit_id", dependent: :destroy

  # Validations
  validates :pure_credit_limit, presence: true, numericality: { greater_than: 0 }
  validates :reserved_credit, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :outstanding_balance, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true, length: { is: 3 }
  validates :pure_credit_start_date, presence: true

  # Scopes
  scope :by_currency, ->(curr) { where(currency: curr) }
  scope :with_temporary_credit, -> { where.not(temporary_credit_limit: nil) }
  scope :expired_temporary_credit, -> { where("temporary_credit_expiry_date < ?", Time.current) }

  # Methods
  def available_credit
    pure_credit_limit + (temporary_credit_limit || 0) - reserved_credit - outstanding_balance
  end

  def has_temporary_credit?
    temporary_credit_limit.present? && temporary_credit_expiry_date.present?
  end

  def temporary_credit_expired?
    return false unless has_temporary_credit?
    temporary_credit_expiry_date < Time.current
  end

  def total_credit_limit
    pure_credit_limit + (temporary_credit_limit || 0)
  end

  def credit_utilization_percentage
    return 0 if total_credit_limit.zero?
    (outstanding_balance / total_credit_limit * 100).round(2)
  end

  def is_over_limit?
    outstanding_balance > total_credit_limit
  end
end

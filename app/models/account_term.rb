class AccountTerm < ApplicationRecord
  self.primary_key = "member_id"
  self.table_name = "account_term"

  # Associations
  belongs_to :account, foreign_key: "member_id", primary_key: "member_id"

  # Validations
  validates :member_id, presence: true, length: { maximum: 10 }
  validates :credit_term_print, presence: true, numericality: { greater_than: 0 }
  validates :credit_term_real, presence: true, numericality: { greater_than: 0 }

  # Scopes
  scope :by_print_term, ->(days) { where(credit_term_print: days) }
  scope :by_real_term, ->(days) { where(credit_term_real: days) }

  # Methods
  def terms_match?
    credit_term_print == credit_term_real
  end

  def print_term_days
    credit_term_print
  end

  def real_term_days
    credit_term_real
  end

  def term_difference
    credit_term_real - credit_term_print
  end
end

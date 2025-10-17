class AccountGuarantee < ApplicationRecord
  self.table_name = "account_guarantee"

  # Associations
  belongs_to :account, foreign_key: "member_id", primary_key: "member_id"

  # Validations
  validates :member_id, presence: true, length: { maximum: 10 }
  validates :type, presence: true, length: { maximum: 50 }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true, length: { is: 3 }
  validates :start_date, presence: true

  # Scopes
  scope :active, -> { where(deleted_date: nil) }
  scope :expired, -> { where("expiry_date < ?", Time.current) }
  scope :by_type, ->(type) { where(type: type) }
  scope :by_currency, ->(curr) { where(currency: curr) }
  scope :document_returned, -> { where(is_document_returned: true) }
  scope :document_not_returned, -> { where(is_document_returned: false) }

  # Methods
  def is_active?
    deleted_date.nil?
  end

  def is_expired?
    return false unless expiry_date.present?
    expiry_date < Time.current
  end

  def days_until_expiry
    return nil unless expiry_date.present?
    (expiry_date.to_date - Date.current).to_i
  end

  def is_expiring_soon?(days = 30)
    return false unless expiry_date.present?
    days_until_expiry <= days && days_until_expiry > 0
  end

  def document_returned?
    is_document_returned
  end

  def can_be_deleted?
    is_document_returned? && document_return_date.present?
  end
end

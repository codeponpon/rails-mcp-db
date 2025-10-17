class AccountStore < ApplicationRecord
  self.table_name = "account_store"

  # Associations
  belongs_to :account, foreign_key: "member_id", primary_key: "member_id"

  # Validations
  validates :member_id, presence: true, length: { maximum: 10 }
  validates :store_code, presence: true, length: { maximum: 20 }
  validates :store_name, presence: true, length: { maximum: 255 }

  # Scopes
  scope :by_store_code, ->(code) { where(store_code: code) }
  scope :by_store_name, ->(name) { where("store_name ILIKE ?", "%#{name}%") }

  # Methods
  def display_name
    "#{store_code} - #{store_name}"
  end

  def store_identifier
    store_code
  end
end

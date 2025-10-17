class AccountAddress < ApplicationRecord
  self.table_name = "account_address"

  # Associations
  belongs_to :account, foreign_key: "member_id", primary_key: "member_id"

  # Validations
  validates :member_id, presence: true, length: { maximum: 10 }
  validates :type, presence: true, length: { maximum: 50 }
  validates :address_1, presence: true, length: { maximum: 255 }
  validates :sub_district, presence: true, length: { maximum: 255 }
  validates :district, presence: true, length: { maximum: 255 }
  validates :province, presence: true, length: { maximum: 255 }
  validates :postal_code, presence: true, length: { is: 5 }, format: { with: /\A\d{5}\z/ }

  # Scopes
  scope :by_type, ->(type) { where(type: type) }
  scope :by_province, ->(province) { where(province: province) }
  scope :by_district, ->(district) { where(district: district) }
  scope :with_coordinates, -> { where.not(latitude: nil, longitude: nil) }

  # Methods
  def full_address
    parts = [ address_1, address_2, sub_district, district, province, postal_code ].compact
    parts.join(", ")
  end

  def has_coordinates?
    latitude.present? && longitude.present?
  end

  def coordinates
    return nil unless has_coordinates?
    [ latitude.to_f, longitude.to_f ]
  end

  def address_type
    type
  end

  def is_billing_address?
    type == "billing"
  end

  def is_shipping_address?
    type == "shipping"
  end

  def is_office_address?
    type == "office"
  end
end

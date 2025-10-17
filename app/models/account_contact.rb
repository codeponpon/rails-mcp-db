class AccountContact < ApplicationRecord
  self.table_name = "account_contact"

  # Associations
  belongs_to :account, foreign_key: "member_id", primary_key: "member_id"

  # Validations
  validates :member_id, presence: true, length: { maximum: 10 }
  validates :type, presence: true, length: { maximum: 50 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :phone_no, format: { with: /\A[\d\s\-\+\(\)]+\z/ }, allow_blank: true
  validates :line_id, length: { maximum: 50 }, allow_blank: true
  validates :first_name, length: { maximum: 50 }, allow_blank: true
  validates :last_name, length: { maximum: 50 }, allow_blank: true
  validates :prefix, length: { maximum: 10 }, allow_blank: true

  # Scopes
  scope :by_type, ->(type) { where(type: type) }
  scope :approved, -> { where(is_approved: true) }
  scope :displayed_on_invoice, -> { where(is_displayed_on_invoice: true) }
  scope :with_email, -> { where.not(email: nil) }
  scope :with_phone, -> { where.not(phone_no: nil) }
  scope :with_line, -> { where.not(line_id: nil) }

  # Methods
  def full_name
    parts = [ prefix, first_name, last_name ].compact
    parts.join(" ")
  end

  def has_email?
    email.present?
  end

  def has_phone?
    phone_no.present?
  end

  def has_line?
    line_id.present?
  end

  def is_approved?
    is_approved == true
  end

  def is_displayed_on_invoice?
    is_displayed_on_invoice == true
  end

  def contact_type
    type
  end

  def is_primary_contact?
    type == "primary"
  end

  def is_billing_contact?
    type == "billing"
  end

  def is_technical_contact?
    type == "technical"
  end
end

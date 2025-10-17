class CreditNote < ApplicationRecord
  self.primary_key = "credit_note_no"
  self.table_name = "credit_note"

  # Associations
  belongs_to :account, foreign_key: "member_id", primary_key: "member_id"
  belongs_to :invoice, foreign_key: "invoice_no", primary_key: "invoice_no"
  belongs_to :original_credit_note, class_name: "CreditNote", foreign_key: "original_credit_note_no", primary_key: "credit_note_no", optional: true
  has_many :replaced_credit_notes, class_name: "CreditNote", foreign_key: "original_credit_note_no", primary_key: "credit_note_no"

  # Validations
  validates :credit_note_no, presence: true, length: { maximum: 36 }
  validates :member_id, presence: true, length: { maximum: 10 }
  validates :invoice_no, presence: true, length: { maximum: 36 }
  validates :credit_note_date, presence: true
  validates :credit_note_amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true, length: { is: 3 }
  validates :remaining_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :store_id, presence: true, length: { maximum: 3 }

  # Scopes
  scope :by_member, ->(member_id) { where(member_id: member_id) }
  scope :by_currency, ->(curr) { where(currency: curr) }
  scope :by_store, ->(store_id) { where(store_id: store_id) }
  scope :attached, -> { where.not(attached_date: nil) }
  scope :not_attached, -> { where(attached_date: nil) }
  scope :original, -> { where(original_credit_note_no: nil) }
  scope :replacement, -> { where.not(original_credit_note_no: nil) }

  # Methods
  def is_attached?
    attached_date.present?
  end

  def is_original?
    original_credit_note_no.nil?
  end

  def is_replacement?
    original_credit_note_no.present?
  end

  def used_amount
    credit_note_amount - remaining_amount
  end

  def usage_percentage
    return 0 if credit_note_amount.zero?
    (used_amount / credit_note_amount * 100).round(2)
  end

  def has_remaining_amount?
    remaining_amount > 0
  end

  def is_fully_used?
    remaining_amount == 0
  end

  def can_be_attached?
    !is_attached? && has_remaining_amount?
  end

  def can_be_replaced?
    is_original? && has_remaining_amount?
  end

  def replacement_chain
    return [ self ] if is_original?

    chain = []
    current = self
    while current.original_credit_note.present?
      current = current.original_credit_note
      chain.unshift(current)
    end
    chain << self
    chain
  end

  def days_since_issue
    (Date.current - credit_note_date.to_date).to_i
  end

  def is_old?(days = 90)
    days_since_issue > days
  end

  def status_description
    if is_attached?
      if is_fully_used?
        "Fully Applied"
      elsif has_remaining_amount?
        "Partially Applied"
      end
    else
      "Not Applied"
    end
  end

  def status_color
    if is_attached?
      if is_fully_used?
        "success"
      elsif has_remaining_amount?
        "warning"
      end
    else
      "info"
    end
  end
end

class BillingNoteItem < ApplicationRecord
  self.table_name = "billing_note_item"

  # Associations
  belongs_to :billing_note, foreign_key: "billing_note_no", primary_key: "billing_note_no"

  # Validations
  validates :billing_note_no, presence: true, length: { maximum: 36 }
  validates :document_type, presence: true, length: { maximum: 50 }
  validates :document_no, presence: true, length: { maximum: 36 }
  validates :status, presence: true, length: { maximum: 20 }

  # Scopes
  scope :by_status, ->(status) { where(status: status) }
  scope :by_document_type, ->(type) { where(document_type: type) }
  scope :active, -> { where(canceled_date: nil) }
  scope :cancelled, -> { where.not(canceled_date: nil) }

  # Methods
  def is_active?
    canceled_date.nil?
  end

  def is_cancelled?
    canceled_date.present?
  end

  def document_identifier
    "#{document_type} - #{document_no}"
  end

  def can_be_cancelled?
    status == "pending" || status == "processing"
  end
end

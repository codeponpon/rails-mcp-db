class AccountBillingNoteAttachment < ApplicationRecord
  self.table_name = "account_billing_note_attachment"

  # Associations
  belongs_to :account, foreign_key: "member_id", primary_key: "member_id"

  # Validations
  validates :member_id, presence: true, length: { maximum: 10 }
  validates :document_code, presence: true, length: { maximum: 20 }

  # Scopes
  scope :by_document_code, ->(code) { where(document_code: code) }

  # Methods
  def document_identifier
    document_code
  end
end

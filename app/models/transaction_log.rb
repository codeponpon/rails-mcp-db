class TransactionLog < ApplicationRecord
  self.table_name = "transaction_log"

  # Associations
  belongs_to :account, foreign_key: "member_id", primary_key: "member_id"
  belongs_to :account_credit, foreign_key: "account_credit_id"

  # Validations
  validates :account_credit_id, presence: true
  validates :member_id, presence: true, length: { maximum: 10 }
  validates :event_id, presence: true
  validates :event_type, presence: true, length: { maximum: 50 }
  validates :operation_type, presence: true, length: { maximum: 50 }
  validates :old_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :new_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :doc_ref_type, presence: true, length: { maximum: 20 }
  validates :doc_ref_no, presence: true, length: { maximum: 36 }
  validates :doc_ref_amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true, length: { is: 3 }

  # Scopes
  scope :by_member, ->(member_id) { where(member_id: member_id) }
  scope :by_event_type, ->(type) { where(event_type: type) }
  scope :by_operation_type, ->(type) { where(operation_type: type) }
  scope :by_doc_ref_type, ->(type) { where(doc_ref_type: type) }
  scope :by_currency, ->(curr) { where(currency: curr) }
  scope :recent, ->(days = 30) { where("created_date >= ?", days.days.ago) }
  scope :by_date_range, ->(start_date, end_date) { where(created_date: start_date..end_date) }

  # Methods
  def amount_change
    new_amount - old_amount
  end

  def amount_change_percentage
    return 0 if old_amount.zero?
    (amount_change / old_amount * 100).round(2)
  end

  def is_increase?
    amount_change > 0
  end

  def is_decrease?
    amount_change < 0
  end

  def is_no_change?
    amount_change == 0
  end

  def change_description
    if is_increase?
      "Increased by #{amount_change.abs}"
    elsif is_decrease?
      "Decreased by #{amount_change.abs}"
    else
      "No change"
    end
  end

  def event_type_description
    case event_type
    when "credit_limit_change" then "Credit Limit Change"
    when "payment_received" then "Payment Received"
    when "invoice_created" then "Invoice Created"
    when "credit_note_created" then "Credit Note Created"
    when "billing_note_created" then "Billing Note Created"
    when "order_created" then "Order Created"
    when "guarantee_added" then "Guarantee Added"
    when "guarantee_expired" then "Guarantee Expired"
    else event_type.humanize
    end
  end

  def operation_type_description
    case operation_type
    when "create" then "Create"
    when "update" then "Update"
    when "delete" then "Delete"
    when "approve" then "Approve"
    when "reject" then "Reject"
    when "cancel" then "Cancel"
    else operation_type.humanize
    end
  end

  def doc_ref_type_description
    case doc_ref_type
    when "invoice" then "Invoice"
    when "credit_note" then "Credit Note"
    when "billing_note" then "Billing Note"
    when "payment_receipt" then "Payment Receipt"
    when "order" then "Order"
    when "guarantee" then "Guarantee"
    else doc_ref_type.humanize
    end
  end

  def document_identifier
    "#{doc_ref_type_description} - #{doc_ref_no}"
  end

  def transaction_summary
    "#{event_type_description} (#{operation_type_description}): #{change_description}"
  end

  def is_credit_transaction?
    is_increase?
  end

  def is_debit_transaction?
    is_decrease?
  end

  def days_ago
    (Date.current - created_date.to_date).to_i
  end

  def is_recent?(days = 7)
    days_ago <= days
  end

  def is_old?(days = 90)
    days_ago > days
  end

  def change_color
    if is_increase?
      "success"
    elsif is_decrease?
      "danger"
    else
      "info"
    end
  end

  def operation_color
    case operation_type
    when "create" then "success"
    when "update" then "info"
    when "delete" then "danger"
    when "approve" then "success"
    when "reject" then "danger"
    when "cancel" then "warning"
    else "secondary"
    end
  end
end

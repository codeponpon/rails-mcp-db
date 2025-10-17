class MatchingLog < ApplicationRecord
  self.table_name = "matching_log"

  # Associations
  belongs_to :account, foreign_key: "member_id", primary_key: "member_id"

  # Validations
  validates :member_id, presence: true, length: { maximum: 10 }
  validates :event_type, presence: true, length: { maximum: 50 }
  validates :event_id, presence: true
  validates :operation_type, presence: true, length: { maximum: 50 }
  validates :doc_ref_type, presence: true, length: { maximum: 20 }
  validates :doc_ref_no, presence: true, length: { maximum: 36 }
  validates :doc_ref_old_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :doc_ref_new_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :matching_amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true, length: { is: 3 }
  validates :event_group_id, presence: true

  # Scopes
  scope :by_member, ->(member_id) { where(member_id: member_id) }
  scope :by_event_type, ->(type) { where(event_type: type) }
  scope :by_operation_type, ->(type) { where(operation_type: type) }
  scope :by_doc_ref_type, ->(type) { where(doc_ref_type: type) }
  scope :by_currency, ->(curr) { where(currency: curr) }
  scope :by_event_group, ->(group_id) { where(event_group_id: group_id) }
  scope :recent, ->(days = 30) { where("created_date >= ?", days.days.ago) }
  scope :by_date_range, ->(start_date, end_date) { where(created_date: start_date..end_date) }

  # Methods
  def doc_ref_amount_change
    doc_ref_new_amount - doc_ref_old_amount
  end

  def doc_ref_amount_change_percentage
    return 0 if doc_ref_old_amount.zero?
    (doc_ref_amount_change / doc_ref_old_amount * 100).round(2)
  end

  def is_doc_ref_increase?
    doc_ref_amount_change > 0
  end

  def is_doc_ref_decrease?
    doc_ref_amount_change < 0
  end

  def is_doc_ref_no_change?
    doc_ref_amount_change == 0
  end

  def doc_ref_change_description
    if is_doc_ref_increase?
      "Increased by #{doc_ref_amount_change.abs}"
    elsif is_doc_ref_decrease?
      "Decreased by #{doc_ref_amount_change.abs}"
    else
      "No change"
    end
  end

  def matching_percentage
    return 0 if doc_ref_old_amount.zero?
    (matching_amount / doc_ref_old_amount * 100).round(2)
  end

  def is_full_match?
    matching_amount == doc_ref_old_amount
  end

  def is_partial_match?
    matching_amount < doc_ref_old_amount && matching_amount > 0
  end

  def is_over_match?
    matching_amount > doc_ref_old_amount
  end

  def match_type_description
    if is_full_match?
      "Full Match"
    elsif is_partial_match?
      "Partial Match"
    elsif is_over_match?
      "Over Match"
    else
      "No Match"
    end
  end

  def event_type_description
    case event_type
    when "payment_matching" then "Payment Matching"
    when "credit_note_matching" then "Credit Note Matching"
    when "invoice_matching" then "Invoice Matching"
    when "billing_note_matching" then "Billing Note Matching"
    when "advance_receipt_matching" then "Advance Receipt Matching"
    else event_type.humanize
    end
  end

  def operation_type_description
    case operation_type
    when "match" then "Match"
    when "unmatch" then "Unmatch"
    when "partial_match" then "Partial Match"
    when "auto_match" then "Auto Match"
    when "manual_match" then "Manual Match"
    else operation_type.humanize
    end
  end

  def doc_ref_type_description
    case doc_ref_type
    when "invoice" then "Invoice"
    when "credit_note" then "Credit Note"
    when "billing_note" then "Billing Note"
    when "payment_receipt" then "Payment Receipt"
    when "advance_receipt" then "Advance Receipt"
    else doc_ref_type.humanize
    end
  end

  def document_identifier
    "#{doc_ref_type_description} - #{doc_ref_no}"
  end

  def matching_summary
    "#{event_type_description} (#{operation_type_description}): #{match_type_description} - #{matching_amount}"
  end

  def is_credit_matching?
    [ "credit_note_matching", "advance_receipt_matching" ].include?(event_type)
  end

  def is_payment_matching?
    [ "payment_matching" ].include?(event_type)
  end

  def is_invoice_matching?
    [ "invoice_matching", "billing_note_matching" ].include?(event_type)
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

  def match_color
    if is_full_match?
      "success"
    elsif is_partial_match?
      "warning"
    elsif is_over_match?
      "danger"
    else
      "info"
    end
  end

  def operation_color
    case operation_type
    when "match" then "success"
    when "unmatch" then "danger"
    when "partial_match" then "warning"
    when "auto_match" then "info"
    when "manual_match" then "primary"
    else "secondary"
    end
  end

  def self.group_by_event_group
    group(:event_group_id).count
  end

  def self.total_matching_amount_by_group(event_group_id)
    where(event_group_id: event_group_id).sum(:matching_amount)
  end

  def self.average_matching_percentage_by_group(event_group_id)
    records = where(event_group_id: event_group_id)
    return 0 if records.empty?

    total_percentage = records.sum { |record| record.matching_percentage }
    (total_percentage / records.count).round(2)
  end
end

class DocumentSeqNo < ApplicationRecord
  self.table_name = "document_seq_no"

  # Validations
  validates :branch_code, presence: true, length: { maximum: 3 }
  validates :doc_type, presence: true, length: { maximum: 50 }
  validates :month, presence: true, numericality: { in: 1..12 }
  validates :year, presence: true, numericality: { greater_than: 2000 }
  validates :seq_no, presence: true, numericality: { greater_than: 0 }

  # Scopes
  scope :by_branch, ->(branch) { where(branch_code: branch) }
  scope :by_doc_type, ->(type) { where(doc_type: type) }
  scope :by_year, ->(year) { where(year: year) }
  scope :by_month, ->(month) { where(month: month) }
  scope :current_month, -> { where(month: Date.current.month, year: Date.current.year) }
  scope :by_period, ->(year, month) { where(year: year, month: month) }

  # Methods
  def period
    "#{year}-#{month.to_s.rjust(2, '0')}"
  end

  def period_description
    Date.new(year, month, 1).strftime("%B %Y")
  end

  def next_sequence
    seq_no + 1
  end

  def formatted_sequence
    seq_no.to_s.rjust(6, "0")
  end

  def document_identifier
    "#{branch_code}-#{doc_type}-#{period}-#{formatted_sequence}"
  end

  def is_current_period?
    year == Date.current.year && month == Date.current.month
  end

  def is_past_period?
    Date.new(year, month, 1) < Date.current.beginning_of_month
  end

  def is_future_period?
    Date.new(year, month, 1) > Date.current.beginning_of_month
  end

  def can_increment?
    is_current_period?
  end

  def increment_sequence!
    return false unless can_increment?

    self.seq_no += 1
    save!
  end

  def reset_for_new_period!
    self.seq_no = 0
    save!
  end

  def self.get_next_sequence(branch_code, doc_type)
    current = find_or_create_by(
      branch_code: branch_code,
      doc_type: doc_type,
      year: Date.current.year,
      month: Date.current.month
    )

    current.increment_sequence!
    current.seq_no
  end

  def self.get_formatted_sequence(branch_code, doc_type)
    seq = get_next_sequence(branch_code, doc_type)
    seq.to_s.rjust(6, "0")
  end

  def self.get_document_number(branch_code, doc_type)
    seq = get_formatted_sequence(branch_code, doc_type)
    period = Date.current.strftime("%Y%m")
    "#{branch_code}-#{doc_type}-#{period}-#{seq}"
  end
end

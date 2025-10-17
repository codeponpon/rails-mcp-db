class Job < ApplicationRecord
  self.table_name = "job"

  # Validations
  validates :job_name, presence: true, length: { maximum: 50 }
  validates :max_retry, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :current_retry, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :retry_backoff, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true, length: { maximum: 20 }

  # Scopes
  scope :by_status, ->(status) { where(status: status) }
  scope :by_job_name, ->(name) { where(job_name: name) }
  scope :by_group, ->(group_id) { where(job_group_id: group_id) }
  scope :pending, -> { where(status: "pending") }
  scope :running, -> { where(status: "running") }
  scope :completed, -> { where(status: "completed") }
  scope :failed, -> { where(status: "failed") }
  scope :cancelled, -> { where(status: "cancelled") }
  scope :retryable, -> { where("current_retry < max_retry") }
  scope :exhausted, -> { where("current_retry >= max_retry") }

  # Methods
  def is_pending?
    status == "pending"
  end

  def is_running?
    status == "running"
  end

  def is_completed?
    status == "completed"
  end

  def is_failed?
    status == "failed"
  end

  def is_cancelled?
    status == "cancelled"
  end

  def can_retry?
    current_retry < max_retry
  end

  def retries_exhausted?
    current_retry >= max_retry
  end

  def status_description
    case status
    when "pending" then "Pending Execution"
    when "running" then "Currently Running"
    when "completed" then "Successfully Completed"
    when "failed" then "Failed"
    when "cancelled" then "Cancelled"
    else status.humanize
    end
  end

  def status_color
    case status
    when "pending" then "warning"
    when "running" then "info"
    when "completed" then "success"
    when "failed" then "danger"
    when "cancelled" then "secondary"
    else "secondary"
    end
  end

  def execution_time
    return nil unless last_started_at.present? && last_finished_at.present?
    last_finished_at - last_started_at
  end

  def execution_time_formatted
    return "N/A" unless execution_time.present?

    seconds = execution_time.to_i
    if seconds < 60
      "#{seconds}s"
    elsif seconds < 3600
      "#{seconds / 60}m #{seconds % 60}s"
    else
      hours = seconds / 3600
      minutes = (seconds % 3600) / 60
      "#{hours}h #{minutes}m"
    end
  end

  def next_retry_delay
    return 0 if current_retry == 0
    retry_backoff * (2 ** (current_retry - 1))
  end

  def next_retry_time
    return nil unless can_retry?
    Time.current + next_retry_delay.seconds
  end

  def has_job_data?
    job_data.present?
  end

  def has_job_result?
    job_result.present?
  end

  def is_grouped?
    job_group_id.present?
  end

  def can_be_cancelled?
    [ "pending", "running" ].include?(status)
  end

  def can_be_retried?
    is_failed? && can_retry?
  end

  def progress_percentage
    case status
    when "pending" then 0
    when "running" then 50
    when "completed" then 100
    when "failed" then 0
    when "cancelled" then 0
    else 0
    end
  end

  def retry_percentage
    return 0 if max_retry.zero?
    (current_retry.to_f / max_retry * 100).round(2)
  end
end

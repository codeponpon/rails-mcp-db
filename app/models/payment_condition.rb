class PaymentCondition < ApplicationRecord
  self.table_name = "payment_condition"

  # Associations
  belongs_to :account, foreign_key: "member_id", primary_key: "member_id"

  # Validations
  validates :member_id, presence: true, length: { maximum: 10 }
  validates :schedule_type, presence: true
  validates :is_active, inclusion: { in: [ true, false ] }

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }
  scope :by_schedule_type, ->(type) { where(schedule_type: type) }

  # Methods
  def is_active?
    is_active
  end

  def schedule_description
    case schedule_type
    when "monthly"
      "Monthly on day #{day_of_month}"
    when "weekly"
      "Weekly on #{day_of_week}"
    when "bi_weekly"
      "Bi-weekly on #{day_of_week}"
    when "quarterly"
      "Quarterly in week #{week_of_month} on #{day_of_week}"
    when "custom"
      "Custom: Day #{start_day} to #{end_day}"
    else
      schedule_type.humanize
    end
  end

  def next_payment_date
    return nil unless is_active?

    case schedule_type
    when "monthly"
      next_monthly_date
    when "weekly"
      next_weekly_date
    when "bi_weekly"
      next_bi_weekly_date
    when "quarterly"
      next_quarterly_date
    when "custom"
      next_custom_date
    end
  end

  private

  def next_monthly_date
    return nil unless day_of_month.present?

    current_date = Date.current
    next_date = Date.new(current_date.year, current_date.month, day_of_month)
    next_date = next_date.next_month if next_date <= current_date
    next_date
  end

  def next_weekly_date
    return nil unless day_of_week.present?

    current_date = Date.current
    target_day = Date::DAYNAMES.index(day_of_week.capitalize)
    return nil unless target_day

    days_ahead = (target_day - current_date.wday) % 7
    days_ahead = 7 if days_ahead == 0
    current_date + days_ahead.days
  end

  def next_bi_weekly_date
    return nil unless day_of_week.present?

    current_date = Date.current
    target_day = Date::DAYNAMES.index(day_of_week.capitalize)
    return nil unless target_day

    days_ahead = (target_day - current_date.wday) % 14
    days_ahead = 14 if days_ahead == 0
    current_date + days_ahead.days
  end

  def next_quarterly_date
    return nil unless week_of_month.present? && day_of_week.present?

    current_date = Date.current
    target_day = Date::DAYNAMES.index(day_of_week.capitalize)
    return nil unless target_day

    # Calculate next quarterly date (simplified)
    next_quarter = current_date.beginning_of_quarter + 3.months
    next_quarter + (week_of_month.to_i - 1).weeks + (target_day - next_quarter.wday) % 7
  end

  def next_custom_date
    return nil unless start_day.present? && end_day.present?

    current_date = Date.current
    current_day = current_date.day

    if current_day >= start_day && current_day <= end_day
      # Within the custom range, next occurrence next month
      current_date.next_month.beginning_of_month + (start_day - 1).days
    else
      # Outside the custom range, next occurrence this month or next
      this_month = Date.new(current_date.year, current_date.month, start_day)
      if this_month > current_date
        this_month
      else
        this_month.next_month
      end
    end
  end
end

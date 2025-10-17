class CreditCheckRule < ApplicationRecord
  self.table_name = "credit_check_rule"

  # Validations
  validates :customer_type, presence: true, length: { maximum: 20 }
  validates :is_overdue, inclusion: { in: [ true, false ] }
  validates :is_bg_expire, inclusion: { in: [ true, false ] }
  validates :is_over_limit, inclusion: { in: [ true, false ] }
  validates :is_cheque_returned, inclusion: { in: [ true, false ] }
  validates :order_status, presence: true, length: { maximum: 20 }
  validates :cv_status, presence: true, length: { maximum: 20 }
  validates :order_eligibility, presence: true, length: { maximum: 100 }
  validates :new_order_status, presence: true, length: { maximum: 20 }

  # Scopes
  scope :by_customer_type, ->(type) { where(customer_type: type) }
  scope :by_order_status, ->(status) { where(order_status: status) }
  scope :by_cv_status, ->(status) { where(cv_status: status) }
  scope :overdue_rules, -> { where(is_overdue: true) }
  scope :bg_expire_rules, -> { where(is_bg_expire: true) }
  scope :over_limit_rules, -> { where(is_over_limit: true) }
  scope :cheque_returned_rules, -> { where(is_cheque_returned: true) }

  # Methods
  def rule_description
    conditions = []
    conditions << "Customer Type: #{customer_type}"
    conditions << "Overdue: #{is_overdue? ? 'Yes' : 'No'}"
    conditions << "BG Expired: #{is_bg_expire? ? 'Yes' : 'No'}"
    conditions << "Over Limit: #{is_over_limit? ? 'Yes' : 'No'}"
    conditions << "Cheque Returned: #{is_cheque_returned? ? 'Yes' : 'No'}"
    conditions << "Order Status: #{order_status}"
    conditions << "CV Status: #{cv_status}"

    "#{conditions.join(', ')} → #{order_eligibility} (#{new_order_status})"
  end

  def matches_conditions?(account)
    return false unless account.customer_type == customer_type
    return false unless account.is_overdue == is_overdue
    return false unless account.is_guarantee_expired == is_bg_expire
    return false unless account.is_over_limit == is_over_limit
    return false unless account.is_cheque_returned == is_cheque_returned
    return false unless account.order_status == order_status
    return false unless account.cv_status == cv_status

    true
  end

  def self.find_matching_rule(account)
    all.find { |rule| rule.matches_conditions?(account) }
  end

  def self.get_order_eligibility(account)
    rule = find_matching_rule(account)
    rule&.order_eligibility
  end

  def self.get_new_order_status(account)
    rule = find_matching_rule(account)
    rule&.new_order_status
  end

  def is_overdue?
    is_overdue
  end

  def is_bg_expire?
    is_bg_expire
  end

  def is_over_limit?
    is_over_limit
  end

  def is_cheque_returned?
    is_cheque_returned
  end

  def eligibility_description
    case order_eligibility
    when "allowed" then "Order Allowed"
    when "restricted" then "Order Restricted"
    when "blocked" then "Order Blocked"
    when "requires_approval" then "Requires Approval"
    else order_eligibility.humanize
    end
  end

  def eligibility_color
    case order_eligibility
    when "allowed" then "success"
    when "restricted" then "warning"
    when "blocked" then "danger"
    when "requires_approval" then "info"
    else "secondary"
    end
  end

  def new_status_description
    case new_order_status
    when "pending" then "Pending"
    when "approved" then "Approved"
    when "rejected" then "Rejected"
    when "on_hold" then "On Hold"
    else new_order_status.humanize
    end
  end

  def new_status_color
    case new_order_status
    when "pending" then "warning"
    when "approved" then "success"
    when "rejected" then "danger"
    when "on_hold" then "info"
    else "secondary"
    end
  end

  def rule_priority
    # Higher priority for more restrictive rules
    priority = 0
    priority += 1 if is_overdue?
    priority += 1 if is_bg_expire?
    priority += 1 if is_over_limit?
    priority += 1 if is_cheque_returned?
    priority
  end

  def is_restrictive?
    [ "restricted", "blocked" ].include?(order_eligibility)
  end

  def is_permissive?
    order_eligibility == "allowed"
  end

  def requires_approval?
    order_eligibility == "requires_approval"
  end
end

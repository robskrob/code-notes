class User
  delegate :price,
    to: :account,
    allow_nil: true
end

class Account
  delegate :price,
    to: :subscription,
    allow_nil: true
end

class PlanSubscription
  def price
    plan.price
  end
end

class MeteredSubscription
  COST_PER_KILOBYTE = 0.01

  def price
    COST_PER_KILOBYTE * kilobytes_used
  end
end

class Account
  def charge_for_subscription
    credit_card.charge(subscription.price)
  end
end

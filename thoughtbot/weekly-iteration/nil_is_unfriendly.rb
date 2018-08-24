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

Account.find_each do |account|
  begin
    account.charge_for_subscription
  rescue NoMethodError => exception
    Airbrake.notify(exception)
  end
end

Account.find_each do |account|
  begin
    account.charge_for_subscription
  rescue NoCreditCardError => exception
    Airbrake.notify(exception)
  end
end

class Account
  def charge_for_subscription
    credit_card.charge(subscription.price)
  end
end

class Account
  def charge_for_subscription
    nil.charge(subscription.price)
  end
end

class Account < ActiveRecord::Base
  class NoCreditCardError < StandardError
  end

  def credit_card
    super || raise NoCreditCardError
  end
end

class Account
  def status
    if last_charge = subscription.last_charge
      "Charged #{last_charge.amount}" \
        "on #{last_charge.created_at}"
    end
  end
end

class Account
  def status
    if last_charge = subscription.last_charge
      "Charged #{last_charge.amount}" \
        "on #{last_charge.created_at}"
    else
      'Pending'
    end
  end
end

class Account
  def status
    subscription.
      last_charge.
      map { |charge|
        "Charged #{last_charge.amount}" \
          "on #{last_charge.created_at}"
    }.
    unwrap_or('Pending')
  end
end

class Some
  def initialize(object)
    @object = object
  end

  def map
    Some.new yield(@object)
  end

  def unwrap_or(default)
    @object
  end
end

class None
  def map
    self
  end

  def unwrap_or(default)
    default
  end
end

# Obeying the Law of Demeter
# 1. itself
class User
  def full_name
    "#{first_name} #{last_name}"
  end

  attr_reader :first_name, :last_name
end

# 2. its parameters
class TaxCalculator
  def tax(amount)
    amount.to_f * @tax_rate
  end
end

# 3. any objects it creates/instantiates
class Order
  def tax
    tax_calculator = TaxCalculator.new
    subtotal + tax_calculator.tax(subtotal)
  end
end

# 4. its direct component objects
class Order
  def initialize(tax_calculator)
    @tax_calculator = TaxCalculator.new
  end

  def tax
    subtotal + @tax_calculator.tax(subtotal)
  end
end

# Violations of the Law of Demeter:
class User
  def discounted_plan_price(discount_code)
    coupon = Coupoon.new(discount_code)
    coupon.discount(account.plan.price)
  end
end

class User
  def discounted_plan_price(discount_code)
    coupon = Coupoon.new(discount_code)
    plan = account.plan
    coupon.discount(plan.price)
  end
end

class User
  def discounted_plan_price(discount_code)
    account.discounted_plan_price(discount_code)
  end
end

class Account
  def discounted_plan_price(discount_code)
    coupon = Coupon.new(discount_code)
    coupon.discount(plan.price)
  end
end

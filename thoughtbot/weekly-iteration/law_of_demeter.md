# Law of Demeter (LOD)
#thoughtbot

+ finished watching

> A method of an object should invoke only the methods of the following kinds of objects:
> 1. itself
> 2. its parameters
> 3. any objects it creates/instantiates
> 4. its direct component objects

```ruby
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
```

The first 3 I understand. Number `4` can apply for instance to other collaborators of an object which are set via a constructor -- so any instance variables.

When we follow the law of Demeter making changes in our system becomes easier. LOD is about how we manage dependencies.

### Violations of the Law of Demeter

1. Multiple Dots

This does not let objects manage their own dependencies. In the below example we are not letting account manage its dependency, `plan`. `plan` is an object that belongs to `account`. An instance of `User` should not be accessing data that belongs to `account`. 

```ruby
class User
  def discounted_plan_price(discount_code)
    coupon = Coupoon.new(discount_code)
    coupon.discount(account.plan.price)
  end
end
```
1.B Same example as above - but less obvious:

```ruby
class User
  def discounted_plan_price(discount_code)
    coupon = Coupoon.new(discount_code)
    plan = account.plan
    coupon.discount(plan.price)
  end
end
```

*Solution - Delegators*

```ruby
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
```

**But Wait!**

* Writing lots of delegators can cover up larger issues with domain model.
* Use Law of Demeter violations as opportunities to review your dependencies.

If you find yourself needing to reach through an object a lot then what you probably want is that object instead of the intermediary object. This is a sign that you should probably refactor your code such that you get the dependency directly -- and not just delegate through a bunch of intermediary objects to get what you want.

### Don't fix violations. Fix actual problems.

* Many delegate methods to the same object?
* Delegate methods with prefix? `author_name`
* Multiple prefixes? `account_plan_price`
* "Fix" by assigning to instance variables?

### Looks like LOD violations but are NOT:
* Daisy chaining method calls on an object of the same type is permissible under LOD: 
  * `user.should_receive(:save).once.and_return(true)`
  * `users.select(&:active?).map(&:name)`
  * `collection_name.singularize.classify.constantize`

### Duplication
* Every time you query your modeling graph, association after association like: `user.account.credit_card` -- you are adding one more place in your code where this dependency graph is rigid and hardcoded in your system. In this example `user.account.credit_card` now you need users to belong to an account, which belong to a credit card. Moreover if you change how users get credit cards then you have to find every single place where you assumed that dependency works that way and change it. This is painful.
* Dependency and Relationship Management - you want to keep things as fluid as possible. You want to make sure as few places in the code as possible understand the relationships between the objects. Instead, your system should just work directly on the messages available to those objects.
* You want to grow your system of objects that do not require a lot of context. You never want your software to only work in specific contexts like when users who have a accounts have credit cards -- `user.account.credit_card`.

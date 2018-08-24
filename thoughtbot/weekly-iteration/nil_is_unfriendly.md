# Nil is Unfriendly, with Joe Ferris
#thoughtbot

- finished watching

## nil is unfriendly -- three options to use instead of nil
1. NullObject when `nil` is always handled the same way
2. Exceptions when `nil` is always a bug
3. Maybe when `nil` needs to be handled specially each time

## Why is Nil unfriendly?
* if you chain a list of methods then you have to check for `nil` every step of the way which creates code that is hard to maintain.
* `nil` adds no meanding. Does it mean, zero, unknown, invalid, bug, false ...?
* `nil` is not a duck. `nil` does not respond to anything. The below is duck typing. These two classes are both different. They do not need either a declared interace or a shared super class. All they need to do is respond to `#price`, and they are ducks. This is useful because any collaborator with a `#price` will work for `#charge_for_subscription`. The collaborator does not need to be a specific subscription class -- anything with a `#price` will do. However, when the collaborator is `nil` you cannot flexibly call a method on it. `nil` is a lousy duck.
* everything is in this binary state: either you have the thing that you thought you did or you have `nil`: `price = subscription.try(:price) || 0`
```ruby
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

# duck typing example
class Account
  def charge_for_subscription
    credit_card.charge(subscription.price)
  end
end

# unfriendly nil example
# nil is a lousy duck
class Account
  def charge_for_subscription
    credit_card.charge(nil)
  end
end
```

## Alternatives to using `nil`

### 1. NullObject pattern
* Helps encapsulate conditional logic. Encapsulates `if`s and sneaky conditionals like, `price = subscription.try(:price) || 0` in one place.
* Encapsulate logic around nothingness -- helps encapsulate the logic around what to do if something is missing into one location so at least you do not repeat it everywhere.
* It allows you to go back to the solid world of Polymorphism with duck typing.
* Lets you handle `nil` in the same way.
* It makes your `nil` state explicit. Instead of just returning `nil` from this `object.price` you can return a `NullPrice` instance or something even more explicit like, `UnsetPrice`.

Using the above example with subscriptions the null object here could be:
```ruby
class FreeSubscription
  def price
    0
  end
end
```

### Tell, Don't Ask

You still do not want to violate tell don't ask. So do not do this:
```ruby
if subscription.is_a?(FreeSubscription)

end
```

The above question should not be asked in numerous places in your app.

### 2. Exceptions
Caveat: Exceptions are for exceptional situations -- something really bad has happened and we need to let you know.
* Encapsulate conditional logic -- pushes it into one specific place.
* Avoid invalid situations. `nil` represents an unexpected outcome.
* Prevent hard-to-debug issues
* When `nil` is unexpected
* `NoMethodError`, `NameError`, `SyntaxError` -- You should never rescue these errors ever because it sounds like you have no idea what your code is doing. For example there is no reason why you should be calling methods that do not exist. This is a terrible way to catch exceptions:
```ruby
Account.find_each do |account|
  begin
    account.charge_for_subscription
  rescue NoMethodError => exception
    Airbrake.notify(exception)
  end
end
```

You should just let the above fail loudly and stop iterating through the loop.
* Instead of rescueing `NoMethodError`, `NameError`, `SyntaxError` raise an explicit error `NoCreditCardError`. This exception is raised precisely where the problem occurs. Raising the exception precisely where the problem happens prevents the 'contagious' nil from getting out and spreading around your program. Moreover the continuation path of this program is better because the error is more specific -- because we know the reason for failure we can feel better about letting the program continue. Whereas if the program crashes because of a `NoMethodErrer` then it makes no sense for the program to continue because we have absolutely no idea why the problem is ocurring:

```ruby
class Account < ActiveRecord::Base
  class NoCreditCardError < StandardError
  end

  def credit_card
    super || raise NoCreditCardError
  end
end

Account.find_each do |account|
  begin
    account.charge_for_subscription
  rescue NoCreditCardError => exception
    Airbrake.notify(exception)
  end
end
```

```ruby
Account.find_each do |account|
  account.charge_for_subscription
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
```

### Maybe Pattern -- this is a pattern for replacing, nil
* Forces conditional logic
* Avoid invalid scenarios
* nils need individual handling

### Law of Demeter
When we violate the law of demeter we are accessing something's state that is not part of your own object's state or arguments passed into a method.

Violation of the law of demeter also indicates duplication. When you traverse an object's state with numerous dots it is likely that you will do this again somewhere else -- which is duplication. If you make a change to this chain of methods you will have to make many changes as a result across the app.

Instead of:
`user.account.subscription.price`

Use `delegate` which will let you write `user.price`, which obeys the law of demeter.
```ruby
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
```
However `nil` still bites you on the above because one of the models could be `nil`.

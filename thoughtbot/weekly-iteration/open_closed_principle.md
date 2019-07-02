# Open Closed Principle

[Open-Closed Principle | Online Video Tutorial by thoughtbot](https://thoughtbot.com/upcase/videos/open-closed-principle)

#thoughtbot

+ finished watching

start watching again from 00:12:00

Open Closed Principle (OCP) -- what if once I wrote code and never changed it?

Definition: Open for extension but closed for modification.

Open for extension -- we want to be able to change the behavior or something, extend its behavior. However, we want to be able to do it with out chaning it so we want to make the code we write closed to a code changing.

```ruby
# Disobeys OCP by using a concrete object
class Purchase
  def charge_user!
    Stripe.charge(user: user, amount: amount)
  end
end

# follows OCP by depending on an abstraction -- Polymorphism:
class Purchase
  def charge_user!(payment_processor)
    payment_processor.charge(user: user, amount: amount)
  end
end
```

Violating OCP:
In the above example OCP is disobeyed when a hardcoded constant is referenced to send a charge to Stripe. If our payment processor changes then we would need to update the above code with a physical code change.

Observing OCP:
The above example also has code that obeys OCP because we rely on an abstraction -- `payment_processor`. By using ducktyping, `payment_processor` can be any number of collaborators provided that it has `#charge` as an interface. In this example the code is open to new behavior by being any type of `payment_processor`. No physical code change is required. In short we can extend the behavior of the `Purchase` class by passing in a different `payment_processor` at runtime without modifying the class.

```ruby
# Disobeys OCP by checking type, and contains an infectious case statement
class Printer
  def initialize(item)
    @item = item
  end

  def print
    thing_to_print = case @item
                     when Text
                       @item.to_s
                     when Image
                       @item.filename
                     when Document
                       @item.formatted
                     end
    send_to_printer(thing_to_print)
  end
end

# Follows OCP by using polymorphism
class Printer
  def initialize(item)
    @item = item
  end

  def print
    send_to_printer(@item.printable_representation)
  end
end
```

Violating OCP:
In the above example if we add a new type to `Printer#print` we need to change the method. We also need to change `Printer#print` if any of the ways for printing an `@item` change.

Observing OCP - Polymorphism:
To obey OCP, we delegate the responsibility of how an item represents itself for printing to the runtime instance of `@item`. For this to work, each `@item` would need to perform `#printable_representation`. Here we can extend `Printer` by adding a new `@item` type that is printable as long as it responds to `printable_representation` we will not need to modify the class.

With the above examples we have been observing OCP with dependency injection. Moreover, without some form of dependency injection we can not really follow OCP.

```ruby
# Disobeys OCP
class Unsubscriber
  def unsubscribe!
    SubscriptionCanceller.new(user).process
    CancellationNotifier.new(user).notify
    CampfireNotifier.announce_sad_news(user)
  end
end

# Follows OCP
class UnsubscriptionCompositeObserver
  def initialize(observers)
    @observers = observers
  end

  def notify(user)
    @observers.each do |observer|
      observer.notify(user)
    end
  end
end

class Unsubscriber
  def initialize(observer)
    @observer = observer
  end

  def unsubscribe!(user)
    observer.notify(user)
  end
end

# Other wins:
#   * Free extension point: order
#   * Unsubscriber is ignorant of how many observers are involved
#   * One place for handling failures, aggregations, etc in the composite class
#   * Can create nested structures of composites
```

### Composite Design pattern - collection objects

If one iterates over a collection -- especially in more than one place -- one should think about what composite abstraction to use to express what that iteration is doing. 

Composite objects can also express nesting (see example: `design_pattern/composite_method.rb`), a composite that composes another composite that composes another...this often makes sense for complex single actions that involve a lot of sub systems such as, payment processing. When an order is placed a lot of things will have to happen like: charging someone's credit card, notifying the accounting system, sending emails to subscribers, adding access to certain things -- each of thes subsystems can have each of their own composite of dependencies. You can have one composite of all of the billing stuff that has to happen, one composite for all of the access stuff that has to happen, one for all of the notifications etc... You can build just one composite that encompossases all of those and now you have a good domain model which makes your code fit the terrain of your problem.

In the above example, an instance of of `Unsubscribe` is constructed with an instance of `UnsubscriptionCompositeObserver`, which was constructed with an array of `observers`, each `observer` responds to `#notify`. The list of `observers` in `Unsubscriptioncompositeobserver` can be any class as long as it has a public API `#notify`. The instance of `Unsubscribe` calls `#unsubscribe!` which calls `Unsubscriptioncompositeobserver#notify` and `Unsubscriptioncompositeobserver#notify` loops through each of its `@observers` and calls `SomeClass#notify`.

As the above example demonstrates the `Unsubscriber` has an easier time when OCP is followed. They just need to know to pass `#notify(user)` to an observer. However when OCP is disobeyed `Unsubscriber` has a difficult time: it needs to know the list of hard coded objects and it needs to know each object's interface. It's sort of like email sending. When you send an email to a person you do not know if it's an individual person or if its a distribution list and you do not care. 

We get a few wins here:
* We've extended the behavior of `Unsubscriber` by letting it notify any number of observers. Moreover, we can now specify the order in which those observers fire a notification.
* One place for handling failures in the composite class. With the composite class we can now handle:
  * publishing an exception in the middle of the loop and behaving however we want it to for an exception - bail out and revert everything, wrap the whole thing in a transaction, continue processing if something failed etc....
  * we can now log how long it takes for all the observers to finish notifying.

### Decorator pattern
Imagine you have a class and you want to extend its behavior bit -- you can compose a new class and wrap a few methods around it to change that behavior.  

### Less Hardcoded dependencies == Less Code Changes
The more dependencies you have interacting in one place the higher the chances are that you will have to change that place / class to change something about that interaction. However if you can represent your dependencies and data like a composite vs a flat dependency list it's much more likely that you can extend that dependency instead of modifying it.

# Open Closed Principle

[Open-Closed Principle | Online Video Tutorial by thoughtbot](https://thoughtbot.com/upcase/videos/open-closed-principle)

#thoughtbot

- finished watching

start watching again from 00:03:53

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

# follows OCP by depending on an abstraction
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

Observing OCP:
To obey OCP, we delegate the responsibility of how an item represents itself for printing to the runtime instance of `@item`. For this to work, each `@item` would need to perform `#printable_representation`. Here we can extend `Printer` by adding a new `@item` type that is printable as long as it responds to `printable_representation` we will not need to modify the class.


With the above examples we have been observing OCP with dependency injection. Moreover, without some form of dependency injection we can not really follow OCP.



# Example 1
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

# Example 2
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
#   * One place for handling failures, aggregations, etc
#   * Can create nested structures of composites

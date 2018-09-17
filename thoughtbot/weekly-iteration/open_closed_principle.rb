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

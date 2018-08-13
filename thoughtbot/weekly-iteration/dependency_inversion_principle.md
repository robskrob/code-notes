# Dependency Inversion Principle
#thoughtbot
#upcase

- Finished watching

[Dependency Inversion Principle | Online Video Tutorial by thoughtbot](https://thoughtbot.com/upcase/videos/dependency-inversion-principle)

Why DIP (Dependency Inversion Principle) is good:
* Makes our dependencies explicit. Typically you do not have to look beyond the constructor of your class to know what your dependencies are.

Obeying DIP (Dependency Inversion Principle):
  * Dependency Injection

    *Violates* DIP
  * Hard code classes in a class — these hardcoded classes create dependencies in your code. Being hardcoded they cannot be switched out without a code change.
* Code that expresses the specific implementations of the business logic vs code that expresses high level, general requirements of the business logic. (`KeyboardReader` vs `reader` and `Printer` vs `writer`)
  * In your tests you will consistently have to stub out class methods instead of stubbing out doubles. Instead of stubbing out class methods you want your tests to just deal with simple doubles.

  *Obeys* DIP:
  * Inject dependencies into class with constructor. The internals of the class is then just using run time objects without any attachment to a hard coded reference of its collaborators.
  * If a dependency you inject into your class has sibling collaborators that use a different API, wrap your collaborators that you want to use the same API in an adapter class. Impose the API you want on the adapter instead and let its implementation know the unique API of the dependency.

  *Obeys* DIP with Framework Classes — no control over constructor:
  * Decorators: If you would like to invert control in an AR model you can create a decorator for your AR model. In Ruby we can use `SimpleDelegator`. Building a decorator class that inherits from `SimpleDelegator` allows the decorator to inherit all of the behavior of the model while also adding addition behavior to the decorator that is related to the model but does not add logic to the model.

  Here’s an example of the above:

### Before Refactor
```ruby
class Product < ActiveRecord::Base
  has_many :purchases
end

class Purchase < ActiveRecord::Base
  belongs_to :product

  # We don't want the receipt responsibilities in Purchase
  def has_receipt?
    receipt.present?
  end

  def receipt_id
    receipt.id
  end

  def receipt_address
    receipt.details.address
  end

  private

  def receipt
    Stripe::Receipt.find(strip_order_id)
  end
end
```

### After - Refactor with a Decorator
```ruby
class Product < ActiveRecord::Base
  has_many :purchases
end

class Purchase < ActiveRecord::Base
  belongs_to :product
end

class PurchaseWithReceipt < SimpleDelegator
  def initialize(purchase, receipt_finder)
    super(purchase)
    @receipt_finder = receipt_finder
  end

  def has_receipts?
    receipts.present?
  end

  def receipt_id
    receipt.id
  end

  def receipt_address
    receipt.details.address
  end

  private

  def receipt
    @receipt_finder.find(@purchase.strip_order_id)
  end
end

class ReceiptCollection
  include Enumerable

  def initialize(purchases, receipt_decorator_factory, receipt_finder)
    @purchases = purchases
    @receipt_decorator_factory = receipt_decorator_factory
    @receipt_finder = receipt_finder
  end

  def each(&block)
    receipts.each(&block)
  end

  private

  def receipts
    @purchases.map do |purchases|
      @receipt_decorator_factory.new(purchase, receipt_finder)
    end
  end
end

# Use:
ReceiptCollection.new(product.purchases, PurchaseWithReceipt, Stripe::Receipt)
```

# Violates DIP
# The explicit dependencies in #copy violates DIP. The class level definition of Copier is coupled to
# KeyboardReader and Printer. They cannot be swaped out.
#
# We have this high level idea of reading this in from somewhere and writing things out. This is the business logic.
# However here we have mixed in the low level details of what the Reader and Writer are.

class Copier
  def self.copy
    reader = KeyboardReader.new
    writer = Printer.new

    keystrokes = reader.read_until_eof
    writer.write(keystrokes)
  end
end

# Obeys DIP. Is decoupled and reusable.

# The below example accomplishes the same business logic as above but leverages the initialize method to
# inject the dependencies.
#
# The dependencies have to obey the interface #write and #read_until_eof with duck typing.
# Here moreover we are unconcerned by what implementations of reading and writing they are.
class Copier
  def initialize(reader, writer)
    @reader = reader
    @writer = writer
  end

  def copy
    @writer.write(@reader.read_until_eof)
  end
end

Copier.new(KeyboardReader.new, Printer.new)
Copier.new(KeyboardReader.new, NetworkPrinter.new)

# Violates DIP

class UserCharger
  def initialize(user)
    @user = user
  end

  def charge!
    Stripe::Customer.charge(@user.stripe_customer_id, MONTHLY_SUBSCRIPTION_FEE)
  end
end

# Obeys DIP
class UserCharger
  def initialize(user, payment_gateway)
    @user = user
    @payment_gateway = payment_gateway
  end

  def charge!
    @payment_gateway.charge(@user.payment_uuid, MONTHLY_SUBSCRIPTION_FEE)
  end
end

# Previous example

class UserCharger
  def initialize
    @user = user
    @payment_gateway = payment_gateway
  end

  def charge!
    @payment_gateway.charge(@user.payment_uuid, MONTHLY_SUBSCRIPTION_FEE)
  end
end

# Low-level class with different interface
class BraintreeGateway
  def create_charge(amount, user_id)
    # ...
  end
end

# Adapted class

class BraintreeGatewayAdapter
  def initialize(braintree_gateway)
    @braintree_gateway = braintree_gateway
  end

  def charge(user_id, amount)
    @braintree_gateway.create_charge(amount, user_id)
  end
end

# Before

class OrderCompleter
  def initialize(order)
    @order = order
  end

  def run
    invoice = Stripe::Charge.create(@order)
    ReceiptSender.new(@order, invoice.id).send
  end
end

describe OrderCompleter do
  describe '#run' do
    it 'sends a receipt' do
      order = double('order')
      invoice = double('invoice', id: 'abc123')
      Strip::Charge.stub(:create).with(order).and_return(invoice)
      receipt_sender = double('receipt_sender', send: true)
      ReceiptSender.stub(:new).with(order, 'abc123').and_return(receipt_sender)

      OrderCompleter.new(order).run

      expect(receipt_sender).to have_received(:send)
    end
  end
end

# After
class OrderCompleter
  def initialize(order, payment_gateway, receipt_sender_factory)
    @order = order
    @payment_gateway = payment_gateway
    @receipt_sender_factory = receipt_sender_factory
  end

  def run
    invoice = @payment_gateway.create(@order)
    @receipt_sender_factory.new(@order, invoice.id).send
  end
end

OrderCompleter.new(order, Strip::Charge, ReceiptSender)

describe OrderCompleter do
  describe '#run' do
    it 'sends receips' do
      order = double('order')
      invoice = double('invoice', id: 'abc123')
      payment_gateway = double('payment_gateway')
      payment_gateway.stub(:create).with(order).and_return(invoice)
      receipt_sender = double('receipt_sender', send: tru)
      receipt_sender_factory = double('receipt_sender_factory')
      receipt_sender_factory.stub(:new).with(order, 'abc123').and_return(receipt_sender)

      OrderCompleter.new(order, payment_gateway, receipt_sender_factory).run

      expect(receipt_sender).to have_received(:send)
    end
  end
end

# Before
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

# After - Refactor with a Decorator
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

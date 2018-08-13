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

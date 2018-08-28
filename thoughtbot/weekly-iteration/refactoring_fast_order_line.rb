# Before Refactor

# fast_order_parser.rb
class FastOrderParser
  attr_reader :errors

  def initialize(user, lines)
    @user = user
    @lines = lines
    @errors = []
  end

  def parse
    FastOrderLine.transaction do
      orders = lines.map.each_with_index do |line, index|
        line.chomp!
        vending_layout = /^(.+\/\d+\/\d+)\|(\d\d-\d\d-\d\d)\|(-?\d+)\|([^|]+)\|([^|]+)$/
        if line.match(vending_layout)
          line = line.match(vending_layout).to_a
          all, location, prnum, qty, ref1, ref2 = line
          entry = FastOrderLine.find_by_entered_prnum_and_checkoutref3_and_user_id_and_checkoutref1(prnum, ref1, user.id, location)
          if entry
            existing_qty = entry.qty
            entry.update_attributes(qty: existing_qty.to_i + qty.to_i)
          else
            FastOrderLine.create!({
              entered_prnum: prnum,
              qty: qty,
              vat_rate: Cart.default_vat_rate,
              line_vat: 0,
              product_id: 0,
              price: 0.0,
              selling_unit: 1,
              special_id: 0,
              user_id: user.id,
              checkoutref1: location,
              checkoutref3: ref1,
              checkoutref4: ref2
            })
          end
        else
          errors << "There was an error on line #{index + 1}"
          errors << "#{line}"
        end
      end

      negative_qtys = FastOrderLine.where('qty < 0')

      if !negative_qtys.empty?
        errors << "You have a negative quantity(s), please fix it, and retry."
      end

      if !errors.empty?
        raise ActiveRecord::Rollback
      end

      zero_qtys = FastOrderLine.where(qty: 0, user_id: user.id)
      zero_qtys.destroy_all if zero_qtys
    end
  end

  private

  attr_reader :lines, :user
end

# fast_order_parser_spec.rb

require 'spec_helper'

describe FastOrderParser do
  context "#parse" do
    it 'creates a fast order line for each parsed line' do
      parse <<-LINES
      F1234/0/1|11-87-17|1|JOHN DOE|COMPANY
      F1234/0/1|11-87-38|1|JOHN DOE|COMPANY
      LINES

      expect(fast_order_attributes).to eq([
        {
          entered_prnum: '11-87-17',
          qty: 1,
          checkoutref1: 'F1234/0/1',
          checkoutref3: 'JOHN DOE',
          checkoutref4: 'COMPANY'
        },
        {
          entered_prnum: '11-87-38',
          qty: 1,
          checkoutref1: 'F1234/0/1',
          checkoutref3: 'JOHN DOE',
          checkoutref4: 'COMPANY'
        }
      ])
    end

    it 'sets default attributes' do
      default_attributes = {
        vat_rate: Cart.default_vat_rate,
        line_vat: 0,
        product_id: 0,
        price: 0.0,
        selling_unit: 1,
        special_id: 0,
        user_id: stub_user.id,
      }

      parse <<-LINES
      F1234/0/1|11-87-17|1|JOHN DOE|COMPANY
      LINES

      order_attributes = FastOrderLine.
        last.
        attributes.
        symbolize_keys.
        slice(*default_attributes.keys)
      expect(order_attributes).to eq(default_attributes)
    end

    it 'combines multiple lines for the same product' do
      parse <<-LINES
      F1234/0/1|11-87-17|1|JOHN DOE|COMPANY
      F1234/0/1|11-87-38|1|JOHN DOE|COMPANY
      F1234/0/1|11-87-38|1|JOHN DOE|COMPANY
      LINES

      expect(fast_order_attributes).to eq([
        {
          entered_prnum: '11-87-17',
          qty: 1,
          checkoutref1: 'F1234/0/1',
          checkoutref3: 'JOHN DOE',
          checkoutref4: 'COMPANY'
        },
        {
          entered_prnum: '11-87-38',
          qty: 2,
          checkoutref1: 'F1234/0/1',
          checkoutref3: 'JOHN DOE',
          checkoutref4: 'COMPANY'
        }
      ])
    end

    it 'returns errors for invalid lines' do
      parser = parse <<-LINES
      F1234/0/1|11-87-17|1|JOHN DOE|COMPANY
      invalid line
      LINES

      expect(FastOrderLine.count).to eq(0)
      expect(parser.errors).to eq([
        'There was an error on line 2',
        'invalid line'
      ])
    end

    it 'returns errors for negative lines' do
      parser = parse <<-LINES
      F1234/0/1|11-87-38|1|JOHN DOE|COMPANY
      F1234/0/1|11-87-38|-1|JOHN DOE|COMPANY
      F1234/0/1|11-87-38|-1|JOHN DOE|COMPANY
      LINES

      expect(FastOrderLine.count).to eq(0)
      expect(parser.errors).to eq([
        'You have a negative quantity(s), please fix it, and retry.'
      ])
    end

    it 'removes purchases for zero quantities' do
      parse <<-LINES
      F1234/0/1|11-87-17|1|JOHN DOE|COMPANY
      F1234/0/1|11-87-38|1|JOHN DOE|COMPANY
      F1234/0/1|11-87-38|-1|JOHN DOE|COMPANY
      LINES

      expect(fast_order_attributes).to eq([
        {
          entered_prnum: '11-87-17',
          qty: 1,
          checkoutref1: 'F1234/0/1',
          checkoutref3: 'JOHN DOE',
          checkoutref4: 'COMPANY'
        }
      ])
    end
  end

  def fast_order_attributes
    compared_attributes = %w(
      entered_prnum
      qty
      checkoutref1
      checkoutref3
      checkoutref4
    )

    FastOrderLine.
      all.
      sort_by { |order| [order.entered_prnum, order.checkoutref1] }.
      map(&:attributes).
      map { |attributes| attributes.slice(*compared_attributes) }.
      map { |attributes| attributes.symbolize_keys }
  end

  def parse(string)
    lines = string.strip_heredoc.scan(/(.*\n)/).flatten
    parser = FastOrderParser.new(stub_user, lines)
    parser.parse
    parser
  end

  def stub_user
    double('user', id: 1)
  end
end

# fast_orders_controller.rb
class FastOrdersController < ApplicationController
  def process_vending
    parser = FastOrderParser.new(current_user, params[:template1].lines)
    parser.parse
    flash[:import_errors] = parser.errors
    redirect_to "/backoffice/fastorder"
  end
end

# After Refactor
class FastOrderParser
  VENDING_FORMAT = /^(.+\/\d+\/\d+)\|(\d\d-\d\d-\d\d)\|(-?\d+)\|([^|]+)\|([^|]+)$/

  attr_reader :errors

  def initialize(user, lines)
    @user = user
    @lines = lines
    @errors = []
    @orders = []
  end

  def parse
    FastOrderLine.transaction do
      build_orders
      if valid?
        save_orders
      end
    end
  end

  private

  def create_or_update_entry(match)
    _, checkoutref1, entered_prnum, qty, checkoutref3, checkoutref4 = match
    order = build_order(entered_prnum, qty, checkoutref1, checkoutref3, checkoutref4)
    entry - find_order_like(order)
    if entry
      entry.qty += order.qty
    else
      @orders << order
    end
  end

  def find_order_like(order)
    @orders.detect do |existing_order|
      existing_order.entered_prnum == order.entered_prnum &&
        existing_order.checkoutref3 == order.checkoutref3 &&
        existing_order.user_id = user.id &&
        existing_order.checkoutref1 == order.checkoutref1
    end
  end

  def build_order(entered_prnum, qty, checkoutref1, checkoutref3, checkoutref4)
    FastOrderLine.new({
      entered_prnum: entered_prnum,
      qty: qty,
      vat_rate: Cart.default_vat_rate,
      line_vat: 0,
      product_id: 0,
      price: 0.0,
      selling_unit: 1,
      special_id: 0,
      user_id: user.id,
      checkoutref1: checkoutref1,
      checkoutref3: checkoutref3,
      checkoutref4: checkoutref4
    })
  end

  def build_orders
    lines.map.each_with_index do |line, index|
      line.chomp!
      match = line.match(VENDING_FORMAT)
      if match.present?
        create_or_update_entry(match.to_a)
      else
        errors << "There was an error on line #{index + 1}"
        errors << "#{line}"
      end
    end
    remove_zero_quantity_orders
  end

  def save_orders
    @orders.map(&:save!)
  end

  def validate
    if has_negative_quantities?
      errors << "You have a negative quantity(s), please fix it, and retry."
    end
  end

  def valid?
    validate
    errors.blank?
  end

  def has_negative_quantities?
    @orders.any? { |order| order.qty < 0}
  end

  def remove_zero_quantity_orders
    @orders.reject! do |order|
      order.qty.zero?
    end
  end

  attr_reader :lines, :user
end

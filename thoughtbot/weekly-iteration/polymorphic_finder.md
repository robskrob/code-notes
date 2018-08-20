# Polymorphic Finder
#thoughtbot

- finished watching

* ApplicationController is a junk drawer. You do not want to feed it more than you have to.
* The method grew in complexity as we added more purchaseable types.
* Common probems could not be implemented in a generic fasion.
* Testing Applicationcontroller methods is awkward.
* Testing the current implementation of the method is repetitous.

## Design Patterns covered
1. Builder
2. Chain of Responsibility
3. Null Object
4. Decorator

## The Builder Pattern

Our polymorphic finder uses the building pattern. Rails uses the builder pattern as demonstrated below via the ActiveRecord Relation API.

```ruby
# our builder
  PolymorphicFinder.
    finding(Section, :id, [:section_id]).
    finding(TeamPlan, :sku, [:team_plan_id]).
    find(params)

# Rails builder pattern

User.
  where(active: true).
  order(:name).
  first!

have_received(:invitation).
  with(user).
  once
```

The above helps fix the **Telescoping Constructor** anti pattern. As you add more options and arguments to the definition, the constructor takes either tons of arguments, a giant hash or an array. When we build our functions the number of arguments are reduced and ordered of arguments are not a problem.

## Chain of Responsibility Pattern

We build up a chain, a linked list of objects, where one points to the next.

## The Null Object pattern
(no description yet...)

`PolymorphicFinder` composes the finder classes. For every builder pattern there needs to be a top level composer for the built objects or functions. 

## Example

```ruby
class Purchase < ActiveRecord::Base
  belongs_to :purchaseable, polymorphic: true
end

# Before refactor

class ApplicationController < ActionController::Base
  def requestable_purchaseable
    if product_param
      Product.find(product_param)
    elsif params[:individual_plan_id]
      IndividualPlan.where(sku: params[:individual_plan_id]).first
    elsif params[:team_plan_id]
      TeamPlan.where(sku: params[:team_plan_id]).first
    elsif params[:section_id]
      Section.where(params[:section_id]).first
    else
      raise "Can't find purchaseable object without an ID"
    end
  end

  def product_param
    params[:product_id] ||
      params[:screencast_id] ||
      params[:book_id] ||
      params[:show_id]
  end
end

# After Refactor

def requestable_purchaseable
  PolymorphicFinder.
    finding(Section, :id, [:section_id]).
    finding(TeamPlan, :sku, [:team_plan_id]).
    finding(IndividualPlan, :sku. [:individual_plan_id]).
    finding(
      Product,
      :id,
      [:product_id, :screencast_id, :book_id, :show_id]
    ).
    find(params)
end

class Finder
  attr_accessor :fallback

  def initialize(relation, attribute, param_name, fallback)
    @relation = relation
    @attribute = attribute
    @param_name = param_name
    @fallback = fallback
  end

  def find(params)
    if id = params[@param_name]
      @relation.where(@attribute => id).first!
    else
      @fallback.find(params)
    end
  end
end

class NullFinder
  def find(params)
    raise(
      ActiveRecord::RecordNotFound,
      "Cant't find a polymorphic record " \
        "without an ID: #{params.inspect}"
    )
  end
end

class PolymorphicFinder
  def initialize(finder)
    @finder = finder
  end

  def self.finding(*args)
    new(NullFinder.new).finding(*args)
  end

  def find(params)
    @finder.find(params)
  end

  def finding(relation, attribute, params_names)
    new_finder =
      param_names.inject(@finder) do |fallback, param_name|
        Finder.new(
          relation,
          attribute,
          param_name,
          fallback
        )
      end

    self.class.new(new_finder)
  end
end
```

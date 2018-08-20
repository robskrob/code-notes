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

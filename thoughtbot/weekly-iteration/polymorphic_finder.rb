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

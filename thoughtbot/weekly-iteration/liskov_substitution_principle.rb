class Signup
  def initialize(attributes)
    @attributes = attributes
  end

  def save
    account = Account.create!(attributes[:account])
    account.users.create!(@attributes)
  end
end

class SignupsController < ApplicationController
  def create
    build_signup.save
  end

  def build_signup
    Signup.new(params[:signup])
  end
end

# Violation of LSP
# This is a violation of LSP because I cannot swap in subclasses for the super class without changing the callers of the class.
# The if statements show a handling of two different APIs at the instance level.

class InvitationSignup < Signup
  def save(invitation)
    user = super
    invitation.accept(user)
    user
  end
end

class SignupsController < ApplicationController
  def create
    signup = build_signup

    if params[:invitation_id]
      invitation = Invitation.find(params[:invitation_id])
      signup.save(invitation)
    else
      signup.save
    end
  end

  def build_signup
    if params[:invitation_id]
      InvitationSignup.new(params[:signup])
    else
      Signup.new(params[:signup])
    end
  end
end

# Refactor to Obey LSP
# Instead of changing the #save methods API we change the constructor's API.
# Make an invitation part of the instance state so that when we get to #save
# the things that have referene to InvitationSignup they do not have to care that there's
# an invitation. They can just call #save.

class InvitationSignup
  def initialize(attributes, invitation)
    super(attributes)
    @invitation = invitation
  end

  def save
    user = super
    @invitation.accept(user)
    user
  end
end

class SignupsController < ApplicationController
  def create
    build_signup.save
  end

  def build_signup
    if params[:invitation_id]
      invitation = Invitation.find(params[:invitation_id])
      InvitationSignup.new(params[:signup], invitation)
    else
      Signup.new(params[:signup])
    end
  end
end

# /users/59/profile

<%= link_to 'Profile', profile_path(@user) %>

resources :users do
  resources :profile
end

class ProfilesController < ApplicationController
  def show
    @user = User.find(params[:user_id])
  end
end

# /users/r00k/profile

class User < ActiveRecord::Base
  def to_param
    username
  end
end

# Violates LSP because the class level API changes from User.find to
# User.find_by_username

<%= link_to 'Profile', profile_path(@user) %>

resources :users do
  resources :profile
end

class ProfilesController < ApplicationController
  def show
    @user = User.find_by_username(params[:user_id])
  end
end

# Refactor to obey LSP
# The fix -- monkey patch ActiveRecord::Base.find to leverage find_by_username
# so the calling part of User.find can continue using User.find

# LSP
# All subsclasses of a superclass must follow the same contract.
# LSP applies to sub class class level methods in the same way.
# friendly_id
# https://github.com/norman/friendly_id
# See an example of friendly_id on learn upcase github project.

class User < ActiveRecord::Base
  def to_param
    username
  end

  def self.find(*args)
    if args.size == 1 && user = find_by_username(args.first)
      user
    else
      super
    end
  end
end

# /users/r00k/profile

class User < ActiveRecord::Base
  def to_param
    username
  end
end

<%= link_to 'Profile', profile_path(@user) %>

resources :users do
  resources :profile
end

class ProfilesController < ApplicationController
  def show
    @user = User.find(params[:user_id])
  end
end

class PaymentsController < ActionController::Base
  def create
    purchase = Purchase.find(params[:purchase_id])
    payment = purchase.process
    redirect_to parment.receipt
  end
end

class Purchase < ActiveRecord::Base
  def process
    payment = Payment.new
    payment.amount = product.price
    payment.receipt = charge_credit_card
    payment.save!
    payment
  end
end

class CreditCardPurchase < Purchase
  def charge_credit_card
    credit_card.charge(product.price)
  end
end

class PaypalPurchase < Purchase
  def charge_credit_card
    paypal.open_transaction(product.price)
  end
end

# this will break because in Paymentscontroller#create we redirect to
# a receipt. In FreePurchase we do not create a receipt.
#
class FreePurchase < Purchase
  def process
    payment = Payment.new
    payment.amount = 0
    payment.save!
    payment
  end
end

# If we couple things their side effects and API can not be too distant from each other.
# If we have two classes that work together in the same way or two methods that inherit from the same classes that work together in a similar way.
# When you make subclasses of the super class you have to make sure that that interaction plays out the same way as the super classes.
#
# If you observe LSP it makes life easer on the callers of your code. If you violate LSP then you potentially have consequences far away
# from your subclass -- more specifically the part of the code that calls your subclass.


# Composition and LSP
class Purchase < ActiveRecord::Base
  def process
    payment = Payment.new
    payment.receipt = processor.process(product.price)
    payment.save!
    payment
  end
end

class CreditCardProcessor
  def process
    credit_card.charge(product.price)
  end
end

class PaypalProcessor
  def process
    paypal.open_transaction(product.price)
  end
end

class FreeProcessor
  def process
    # receipt -- same problem as above with inheritance.
    # This should return a Null object -- a NullReceipt instead of just nil.
  end
end

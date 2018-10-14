# Liskov Substitution Principle (LSP)

#thoughtbot

+ finished watching


### Form Object - Signup

I should be able to swap in subclasses for their parent class with impacting the callers of the class.  

```ruby
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
```

Class methods vs Instance methods

If we expect the API of instance methods to match then we want to be consistent with instance method APIs. This is conversely true with class level methods.

All of the above examples show inheritance experiencing LSP violations. LSP violations can also occurr with Composition.

LSP needs to be applied in any type of `is_a` relationship. In other words, LSP applies when using either inheritance or composition.

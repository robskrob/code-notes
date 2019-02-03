# Single Responsibility Principle (SRP)

#thoughtbot

- finished watching

Pick start watching from 00:05:30

SRP - Single Responsibility Principle
OCP - Open Closed Principle
LSP
ISP
DIP

Definition: A class should have only one reason to change.

Why should a class only have one responsibility?
* Clarity - optimization starts with readability first. When we observe the single responsibility principle our code will be more readable.
* Reusable - classes that have only one responsibility are more likely to be reusable. If you build your system of pieces that are small then you tend to be able to reuse those pieces in more places because they are not bound with other responsibilities. In our example you can just pull out the tokenization as opposed to getting: tokenization + persistance + other things... 
* Testable
* Easier to change:
  * Classes with one responsibility are much easier to change. SOLID lets us build software that is more flexible and resilient so you don't hit that plateau in a project where suddenly you want to rewrite it.
  * In the unrefactord Invite model one has to worry about what happens to the other pieces of this class when I change only one piece. Everything is within the same scope. However, when we focus on making things easier to change we focus on keeping pieces of the system isolated from each other and limited in their own scope, which they do not share -- these isolated pieces do not need to worry about anything else around it.

```ruby

# SRP

# Violation of SRP

class Invitation < ActiveRecord::Base
  EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  STATUSES = %w[pending accepted]

  belongs_to :sender, class_name: 'User'
  belongs_to :survey

  before_create :set_token

  validates :recipient_email, presence: true, format: EMAIL_REGEX
  validates :status, inclusion: { in: STATUSES }

  def to_param
    token
  end

  def deliver
    Mailer.invitation_notification(self).deliver
  end

  private

  def set_token
    self.token = SecureRandom.urlsafe_base64
  end
end

# Observance
# Everything that did not have to do with ActiveRecord has been removed.
# This is just the persistance.

class Invitation < ActiveRecord::Base
  STATUSES = %w[pending accepted]

  belongs_to :sender, class_name: 'User'
  belongs_to :survey

  validates :recipient_email, presence: true, email: true
  validates :status, inclusion: { in: STATUSES }
end

# Observance of SRP
class TokenizedModel > SimpleDelegator
  def save
    __getobj__.token ||= SecureRandom.urlsafe_base64
    __getobj__.save
  end

  def to_param
    __getobj__.token
  end
end


# Example

TokenizedModel.new(invite)

```

A responsibility is a reason to change. Anything that a class is responsible for may need to change because of that responsibility.

Classes should be **cohesive**. The principle of **cohesion** states that every piece of a class should be strongly related to its other pieces. 

If you have a class that is highly cohesive then it's likely that it follows SRP. Moreover, if you follow SRP it is likely that you have a highly cohesive class, which greatly improves readablity. It is much easier to understand things when a class has a flat semantic scope. If everything in other words has to do with emails when you go from method to method you are never surprised.

```ruby
# Violation of the Cohesion principle
# There is no cohesion whatsoever below. Generating a token and validating an email have nothing
# to do with each other.
# This is called 'incidental cohesion' -- these pieces are related only because you put them in the same place.
# Being in the same place is their only common factor.

module Utils
  def self.generate_token
    SecureRandom.urlsafe_base64
  end

  def self.valid_email?(email)
    email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  end
end

# Better cohesion than the above but still not great
class Address
  include ActiveModel::Model

  attr_accessor :street, :apartment_number, :city, :zip

  def to_html
    <<-HTML
      <address>
        #{streeet} #{apartment_number}
        #{city} #{zip}
      <//address>
    HTML
  end

  def apartment?
    apartment_number.present?
  end

  def us?
    zip.present?
  end
end

# Highly cohesive value object
# Everything in this class has to do with that one field -- email.
class Email
  def initialize(string)
    @string = string
  end

  def valid?
    @string = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  end

  def domain
    @string.split('@').last
  end

  def to_s
    @string
  end
end
```

**Practical Advice**

Like most principles or guidelines we cannot apply SRP gloabally all the time. A lot of times it is not always clear what the responsibilities are or will be when you first start writing a class. We tend to want to refactor as we evolve. So what do we tackle first?

When applying SRP a lot of value can be drawn when it is applied to classes in applications that can be called, 'responsibility magnates', like User or Product. 

Great `gem` called, `churn` -- which tells you how many times a class has been changed:

```bash
churn \
  -c 10 \
  -- start_date '1 year ago' \
  -iGemfile,Gemfile.locck, config/routes.rb,db/schema.rb
```
+---------------------------------------+---------------+
| file_path                             | times_changed |
+---------------------------------------+---------------+
| app/views/pages/prime.html.erb        | 46            |
| app/models/user.rb                    | 42            |
| spec/models/user_spec.rb              | 39            |
| app/models/purchase.rb                | 36            |
| app/models/subscription.rb            | 33            |
| app/models/subscription.rb            | 31            |
+---------------------------------------+---------------+

Because the above classes / files change often it's highly likely that you can also say that they have many reasons for changing, which means they have many responsibilities. This tends to happens with the core models. If we work really heard for example to stop ourselves from adding responsibilities to the User model then you are less likely to end up with churn in the User model.

We should prevent responsibilities from easily getting sucked into model magnates.

**Pragmatic Decision Making**

* Has this been a problem in this class before?
* Is this class a responsibility magnate?

**Tell; Don't Ask vs SRP**

Sometimes we fight against one principle when we try to obey the other. For instance Separation of Concern forces us to violate **Tell; Don't Ask** -- each element of MVC has its own responsibility.

Here's an example that demonstrates how SRP violates **Tell; Don't Ask.** In this view the view asks `@account` a question and then immediately makes a decision on `@account`'s behalf because the view does not want to burden `Account` with the knowledge of view responsibility. In this scenario we have values SRP over Tell; Don't Ask.

```erb
<% if @account.invitations_remaining? %>
  <p>
    You have
    <span class="count">
      <%= @account.invitations_remaining%>
    </span>
    remaining.
    <%= link_to 'Invite?', new_invitation_path %>
  </p>
<% else %>
  <p>
    You have no invitations remaining.
    <%= link_to 'Upgrade?', edit_plan_path%>
  </p>
<% end %>

```

```ruby
# The MVC framework can force us to value SRP over Tell; Don't ask.
# The below class would follow SRP to a fault.
class Account
  def invite_html
    if invitations_remaining?
      <<-HTML
        <p>
          You have
          <span class="count">
            <%= @account.invitations_remaining%>
          </span>
          remaining.
          <%= link_to 'Invite?', new_invitation_path %>
        </p>
      HTML
    else
      <<-HTML
        <p>
          You have no invitations remaining.
          <%= link_to 'Upgrade?', edit_plan_path%>
        </p>
      HTML
    end
  end
end
```

We often ignore Tell; Don't Ask in the view, and we just live with that fact that that's always how it's going to be in MVC because we made the decision to split up those concerns in that way and we are just going to 'ask questions' in the view and violate Tell; Don't Ask. The alternative would be to just not use MVC, but MVC has proven to  be helpful so we stick with MVC.

**Metric for code quality**
- How easy is this code to change when the requirements are different? If very easy, then the code is written well. If not, then it is written very poorly.

**Notes**
- Talk by Dave Thomas from pragmatic programmers.

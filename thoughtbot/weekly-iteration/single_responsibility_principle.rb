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

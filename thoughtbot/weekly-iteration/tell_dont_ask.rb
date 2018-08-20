# Not so good
def check_for_overheating(system_monitor)
  if system_monitor.temperature > 100
    system_monitor.sound_alarms
  end
end

# Better
system_monitor.check_for_overheating

class SystemMonitor
  def check_for_overheating
    if temperature > 100
      sound_alarms
    end
  end
end

# Not so good
class Post
  def send_to_feed
    if user.is_a?(TwitterUser)
      user.send_to_feed(contents)
    end
  end
end

# Better
class Post
  def send_to_feed
    user.send_to_feed(contents)
  end
end

class TwitterUser
  def send_to_feed(contents)
    twitter_client.post_to_feed(contents)
  end
end

class EmailUser
  def send_to_feed(contents)
    # no-op.
  end
end

# Not so good

def street_name(user)
  if user.address
    user.address.street_name
  else
    'No street name on file'
  end
end

# Better

def street_name(user)
  user.address.street_name
end

class User
  def address
    @address || NullAddress.new
  end
end

class NullAddress
  def street_name
    'No street name on file'
  end
end

# Violation of tell dont ask
# This is a mixture of command and query methods on the same object, user.
# 1
if user.password.present?
  user.save!
else
  user.errors.add :password, "can't be blank"
end

# 2
# While this is a violation, this one is ok because this is the Rails API for generating a response.
# Moreover in the conditional branches we are not doing something different to the user based on the result of the save.
if @user.save
  ConfirmationMailer.confirmation(@user).deliver
  redirect_to root_url
else
  render 'new'
end

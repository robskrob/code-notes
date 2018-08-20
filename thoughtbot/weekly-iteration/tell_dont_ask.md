# Tell, Don’t Ask
#thoughtbot

- finished watching

[Tell, Don’t Ask | OO Design Patterns Tutorial by thoughtbot](https://thoughtbot.com/upcase/videos/tell-don-t-ask)

Instead of having a dialogue back and forth with your objects, for example: "Are you a User? If so I want your name. If not then I want something else." Instead you want to give your objects simple and concise commands: whatever you are just `save` yourself.

### Not so good

The reason why this example is not so good is because there is no reason why to have this logic here. It would be better to encapsulate this logic in one place and have parts of the system that works with users to just call the `welcome_message` method on the user.

In OO we group behavior and data together. The data on whether or not this user is an admin exists within the current user. We should keep the behavior for what we do when someone is an admin in the user object.

> I feel like I am asking a lot of questions in the view.

### Not so good
```ruby
<% if current_user.admin? %>
  <%= current_user.admin_welcome_message %>
<% else %>
  <%= current_user.user_welcome_message %>
<% end%>
```

### Better
```ruby
<%= current_user.welcome_message %>
```

This example shows a dialogue between objects. One object asks its collaborator things and based on the object's answer the object makes decisions on the object's behalf.

This example shows 'feature envy'. When the same object is being repeatedly referenced in this ask and tell situation of the object, this tells you have a method waiting to be extracted. In other words if all of this logic has to do with system monitors, perhaps it belongs in the system monitor class.

### Not so good
```ruby
def check_for_overheating(system_monitor)
  if system_monitor.temperature > 100
    system_monitor.sound_alarms
  end
end
```

This example shows a dialogue with itself which is acceptable. We just tell it to `check_for_overheating`. We are grouping the logic of the object with its own data that it uses. The system monitor here looks at its own temperature and then does something. Where as the above example asks the collaborator to check for overheating and then does something on behalf of what the other object tells it.

### Better
```ruby
# Better
system_monitor.check_for_overheating

class SystemMonitor
  def check_for_overheating
    if temperature > 100
      sound_alarms
    end
  end
end
```


### Not so good

Same situation again: asking a question of that user instance and then based on the user's answer making a decision for that user in the post instance.

```ruby
class Post
  def send_to_feed
    if user.is_a?(TwitterUser)
      user.send_to_feed(contents)
    end
  end
end
```

### Better

Replace a conditional with polymorphism. For many types of users you create a class with the same API, `EmailUser#send_to_feed, TwitterUser#send_to_feed etc...`.
```ruby
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
```

### Not so good

```ruby
def street_name(user)
  if user.address
    user.address.street_name
  else
    'No street name on file'
  end
end
```

### Better

```ruby
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
```

## Take Aways
* Good OOP is about telling objects what you want done, not querying an object and acting on its behalf.
* If you are doing something to yourself based on a question you ask a collaborating object -- that is fine. However, if you are doing something to the collaborating object based on a question you ask it then that a violation of 'Tell, don't ask'
* 'Tell, don't ask' is a smell - an indication that something could be wrong; there may be a way to improve the code. This does not mean there is something necessarily wrong:
  * You do not go around fixing smells. You look at smells to see if there is a problem they reveal that you can fix.

### Violations
* If you find yourself making conditional branches based on a method on an object and then inside each branch of the condition doing something different with that object **then you a re violating 'tell, don't ask'**
* Mixing command and query methods for the same object. Instead handle decision trees internally -- in the command method and not outside it.


### Observance

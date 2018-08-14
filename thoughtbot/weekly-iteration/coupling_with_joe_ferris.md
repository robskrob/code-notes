# Coupling, with Joe Ferris
#thoughtbot

[Coupling, with Joe Ferris | Online Video Tutorial by thoughtbot](https://thoughtbot.com/upcase/videos/coupling-with-joe-ferris)

*Coupling* is the degree to which the components in a system rely on each other.

Example: If A is tightly coupled to B then changes in B have a good change of affecting A.

Pathological coupling:
* Goes beyond the public interface of the class. If we are reaching into an instance from the outside and directly setting values inside it (`instance_variable_set`) we are not using the public interface which defeats the purpose of an API Design. The API is not even being used.
* Monkey patching falls within the same category. You are fiddling around with the internals of an object and not using its public interface.

```ruby
class NuclearLaunchController
  def initialize(launch_codes)
    @launch_codes = launch_codes
  end
end

class ExtremelyBadIdea
  def initialize(nuclear_launch_controller)
    @launch_controller = nuclear_launch_controller
  end

  def do_bad_things
    # this is poison
    @launch_controller.instance_variable_set(:@launch_codes, 'password')
  end
end
```

Global Coupling:
* Factorygirl factories come from only one central dependency and when a factory is invoked it is always connected to that one central repository. You cannot have different parts of an application use different factories.
* Inheritance and mixing in modules will add a hardcoded dependency in your class. If the dependency changes then all things using it can experience side effects.

```ruby
# Global coupling
# spec/factories.
FactoryGirl.define do
  factory :user do
    # Changes here are global and can affect many test files.
  end
end

# spec/model/user_spec.rb
before do
  # this refers to global data.
  @user = build_stubbed(:user)
end

# spec/model/order_spec.rb
before do
  # So does this.
  @user = build_stubbed(:user)
end
```

Control Coupling:
* The control of a method is coupled to the parameter. The code that is calling the method is passing in a flag that is telling the method what to do. However, if the caller of the method knows what it wants the method to do then it should just call a different method.
* Code smell: when you feel tempted to pass in a boolean flag to a method: do this when true or do that when false.

Data Coupling:
* Using the parameter in the method without forking your behavior on it -- you just use the parameter. In others a method takes a parameter and then just passes the parameter to another method.
* You need to know how your function has to use the parameter that it passes in. In this case, you need to know to call `.to_s` on text for `output_to_screen`.
* My code need to pass in an object that responds to `to_s` otherwise my code `print` will break. The knowledge of how the print method works has leaked into my code. 

```ruby
 ScreenPrinter
  # This method is coupled to its parameter, because a change to that argument
  # can cause breakage (if we did not call, to_s, on text for example)
  def print(text)
    output_to_screen(text.to_s)
  end
end
```

Acceptable coupling
* Your public API requires no arguments. The constructor of the class took care of its dependencies and so the method can just call them when they are needed.

```ruby
class ScreenPrinter
  # No reliance on anything outside this object.
  def print_to_screen
    output_to_screen(@text)
  end
end
```

Take aways:
* Methods with fewer arguments -- the better.

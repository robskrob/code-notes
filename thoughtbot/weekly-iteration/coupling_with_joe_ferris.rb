# Pathological coupling
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

class ScreenPrinter
  # This method is coupled to its parameter, because a change to that argument
  # can cause breakage (if we did not call, to_s, on text for example)
  def print(text)
    output_to_screen(text.to_s)
  end
end

class ScreenPrinter
  # No reliance on anything outside this object.
  def print_to_screen
    output_to_screen(@text)
  end
end

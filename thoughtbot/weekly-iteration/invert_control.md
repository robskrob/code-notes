# Invert Control
+ finished watching

This is a follow up screen cast to, [Extract Class](https://thoughtbot.com/upcase/videos/extract-class)

*Violating* inversion of control looks like:

	* every dependency decides what its dependency will be. Every dependency, ever class, knows what its dependencies are because they are hard coded in the class. Each class’s dependencies are hardened into its self.


	* If your class is in charge of figuring out its dependencies then your class is violating inversion of control. In this situation your class has two responsibilities:
		1. doing the stuff it is suppose to do
		2. managing its dependencies — figuring out how to use and call them.

Invert control allows you to remove how a class needs to figure out how to use its dependencies.

What does Invert Control mean?

*Obeying* inversion of control:
	* Injecting dependencies into the construction of the class will invert control because the dependency has been prepared outside the class. The class does not have control over how the dependency, the other instance, was created so it knows less.
		* With dependency injection we can also swap different implementations of the dependency. To the class the dependency is just a printer and not necessarily a particular class or kind of printer.
	* Provides a container to your system which assembles all of the dependencies to be passed to its collaborators. Often in Rails apps this container — the top level — can be your controller. In the controller action we can assemble and construct all of the dependencies and collaborators and pass them down to the other classes that will use them.
	* a class just has a collaborator as an object — it does not need to know the object’s class to handle it.

```ruby

class Parser
  def initialize(csv)
    @csv = csv
  end

  def recipients
    CSV.parse(@csv, headers: true).map(&:to_hash)
  end
end

class Sender
  def initialize(parser, message)
    @message = message
    @parser = parser
  end

  def send
    recipients.each do |recipient|
      Mailer.invitation(recipient['name'], recipient['email'], @message).deliver
    end
  end

  private

  def recipients
    @parser.recipients
  end
end

class InvitationController < ApplicationController
  def new
  end

  def create
    parse = Parser.new(params[:csv_file].read)
    Sender.new(parser, params[:message]).send
    redirect_to new_invitation_url, notice: 'Invitations sent.'
  end
end
```

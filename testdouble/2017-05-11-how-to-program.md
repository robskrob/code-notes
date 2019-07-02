Workflow

Work -- what programs are, their structure and behavior
Flow -- how we program, our thoughts and actions

Work - CS education
* cryptography
* Big-O() Analysis
* P vs NP
* Data Structures

Work - Bootschools
* node.js / React
* Ruby / Rails
* Unix / Git
* HTML/CSS/JS

Work - Industry Thoughtleaders
* TDD/BDD/`.*DD`
* Scrum/XP/Lean
* SOLID Principles
* Design Patterns

Do
Feel
Think

Trait #1 - Sensitive

Discovery Testing
* Break big scary problems into smaller more manageable ones.
* Start with a test of that top level thing.
* Write a single test case and invoke the thing. Then I ask myself a crucial question, "what's the code that I wish I had that I could defer and hand this work out to?"

```ruby
# The purpose of this test is to discover the 4 clear responsibilities:
# 1. finds_hands
# 2. determine_shakes
# 3. mails_shakes
# 4. remembers_shakes
class HandshakeTest < UnitTest

  def test_handshake
    # create these four fake things
    finds_hands = gimme_next(FindsHands)
    determines_shakes = gimme_next(DeterminesShakes)
    mails_shakes = gimme_next(MailsShakes)
    remembers_shakes = gimme_next(RemembersShakes)
    # sets up a stubbing 
    # when finds hands is called it gives me this thing that symbolizes hands.
    give(finds_hands).find { :hands }
    # And if I pass this thing that symbolizes the hands that determines the shakes 
    # another stubbing will give me these handshakes.
    give(determines_shakes).detemine(:hands) {:shook_hands}

    Handshake.call()

    # I therefore assert that I mail out all those handshakes
    verify(mails_shakes).mail(:shook_hands)
    # and that I assert that I persist them.
    verify(remembers_shakes).remember(:shook_hands)
  end
end

# the above test specifies the behavior of this top level unit, which in code looks like the below:

module Handshake
  def self.call
    hands = FindsHands.new.find
    shook_hands = DeterminesShakes.new.determine(hands)
    MailsShakes.new.mail(shook_hands)
    RemembersShakes.new.remember(shook_hands)
  end
end

# If you list out all the files that shake out to get that test to pass
# now I have pretty clear work cut out for me.
# I know what I need to do.
# I can start making forward progress.

lib
|__ handshake
|   |__ determines_shakes.rb
|   |__ finds_hands.rb
|   |__ mails_shakes.rb
|   |__ remembers_shakes.
|
|__ handshake.rb
```

Trait #2 - Inventive Vs Aesthetic

How do I make my code more discoverable and approachable for other developers?

What if a feature was a, tree?

Value objects are on the left. Feature behavior on the right.

The tree of functionality -- good design ends up looking like a tree. At the top of the tree the program starts and instantiates much of the program. Then each piece of the program branches off and does its unique thing. Those branches may have their own individual branches of unique behavior and at the end of them is a leaf, a piece of behavior that does not delegate further.

Trait #3 - Naive vs Leery


Feature -- Day 1

Our brains can only hold so much stuff in them at once. Developers tend to size features to whatever number of things they can hold in their head at a time. Naturally the objects and methods are the same size as the complexity that we can hold in our heads at any given moment.

Instead of predicting how complexity is going to change and guessing the complexity stuff, I change the question:
> How do I prepare myself and other people for the inevitable increase of complexity? 

On day one of any feature, I break things up into itty bitty tiny units.

The tree of functionality:

The tree of functionality has units which typically take three roles:
1. The parent nodes are delegator objects 
2. Leaf nodes
3. Value objects

Parent nodes are delegator objects. 
* They do not contain much logic. They mostly just break up the work and hand it off to other things. 
* I use Test-Driven Design I use test doubles to identify and think up, "what's the code I wish I had that would actually do the real work?"

What you want to try to maximize is these leaf nodes. This is where the core logic of the application is.

Leaf nodes -- Logic:
* Transforms inputs into some output
* Easy testing with no test doubles
* Functional programming for people who don't want to think too hard.

Value Objects
* Wrap a bit of data
* Methods only elucidate the data (e.g. `left_hand?`)
* Not allowed to do feature work
* The sludge that flows through the feature code's pipes
* They are the types in those method signatures


Trait #3 - Leery
I distrust myself

How to change code?

Disposable architecture
* Justin tries to make his code disposable.
* When I look at my tree of code, I search for all of the effected units of code that the change impacts. Then I find the smallest sub tree that encapsulates that change and then I blow it all up. I delete those pieces -- the leaf and the sub tree.
* I trust that my future self is going to see that top level thing and understand what the contract is and he is going to drive out a new solution vs just changing these old units that implemented the logic the old way. Chaning the old units would wrack up technical debt.
* Instead I trust him to drive out a new solution -- a better solution becuse future self has more experience than present self.

Code reuse isn't free
* any method that's used in 9 places is really hard to change because you have consider 9 different placed callers and what they need.
* It's very hard to throw reusable code and replace it.
* Maintainable code does not have to live forever.

Immortal code that never changes vs Incremental renewal

Incremental renewal:
* rewriting the small pieces as a part of your process -- your flow -- is a way to pay off technical debt. This way you do not have to save up for a rainy day fund where for when you finally get to refactor.
* I will make myself happier. Future me does not want his job to be fixing all of Justin's old janky tests every time future me changes something.
* I want to be able to write code for a living, and so this process by making death a part of life while we're working through features, is a great way to keep your teams happy I've found.

Trait #4
Economical vs Thorough

I'm a control freak

Third party code
* protect 3rd party code from its blast radius.
* wrap 3rd party code 

What does your code look like without wrappers:

```ruby
# 1. calls through to the database but also makes sure that the DB works but only when three quarters of the code paths are fake?
class HandshakeTest < IntegrationTest

  def test_handshake
    # Need to make validations work of course
    users = [
      User.create!(
        name: 'Amber',
        date_of_birth: Time.zone.now
      )
    ]

    determines_shakes = gimme_next(DeterminesShakes)
    mails_shakes = gimme_next(MailsShakes)
    remembers_shakes = gimme_next(RemembersShakes)

    give(determines_shakes).detemine(users) {:shook_hands}

    Handshake.call()

    # I therefore assert that I mail out all those handshakes
    verify(mails_shakes).mail(:shook_hands)
    # and that I assert that I persist them.
    verify(remembers_shakes).remember(:shook_hands)
  end
end

# the above test specifies the behavior of this top level unit, which in code looks like the below:

module Handshake
  def self.call
    # remove wrapper around third party API
    # hands = FindsHands.new.find
    hands = User.all
    shook_hands = DeterminesShakes.new.determine(hands)
    MailsShakes.new.mail(shook_hands)
    RemembersShakes.new.remember(shook_hands)
  end
end
```

Mixing the levels of abstraction in my system is the problem -- mixing wrappers of third party code with literal third party code for instance -- the problem is not having too many abstrations.

Wrapping third party libraries gives you the convenience of having the third party libraries, continuously sucking them in, while also maintaining control in your code base.

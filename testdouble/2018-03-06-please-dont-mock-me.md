* Subject -- the subject under test. Think of a science experiment. This is your subject under test and experimentation.
* Dependency -- anything your subject relies on to get its job done. Usually this is another module that the subject requires.
* Unit Test -- exercises a private API that you own and can change, whether or not it calls through to its real dependencies or not.
* Test Double (stub, spy, mock, fake) -- a fake thing used in your test.

Tests should fail.

When should tests fail?

Tests should fail when their dependencies' behavior changes. Therefore, we should limit / reduce redundant coverage to reduce the overall cost of change. If that dependency is required by 35 other things and you need to change this dependency then you have 35 broken tests, which is useless pain.
Tests should fail when their dependencies' protocol, relationship or contract with the subject / caller changes. Therefore, you should create some kind of integration test, a safety net test, just to make sure everything's plugged-in right.

Instead of critiqueing how much someone is mocking, critique how mocks are used and for what purpose. Discuss the strategy behind a test.

We have a tendency of valuing maximum realness over experimental control.

> Instead of treating 'realness' as a virtue to be maximized, we should clarify what our test is trying to prove and then use all of our tools -- mocks included -- to ensure we have sufficient experimental control.
- Justin Searls

Hard to mock code is hard to use code. The issue is not with the mocks -- it's with how the design of the code.

If something is hard to mock, it's something that you own, a private module with its own API that you can change, the remedy is: change it. That test that's hard to mock is providing you with valuable feedback saying the design of code is hard to use. 

However, if you are mocking a third party thing and it's painful to mock, then you are experiencing useless pain. Instead of mocking out third party dependencies, wrap them in a module, function, or a class instead of mocking it.

Wrappers tucks under a rug all the complexity and how to call it. Instead, you create the API you want and use it, which in its internal implementation it's referencing the API.

Don't write unit tests of your third party wrappers. You do not need to. Just trust that the Third party API works.

We assume tests make change safe, but: what kind of tests, make what kind of change safe?

Tests with no dependencies, no mocking -- a pure function:
- If the logic's rules change, the test needs to change.

> What if the subject has both mocked dependencies and logic?

This is a mixed level of abstraction in your function under test. You should avoid mixed levels of abstraction -- two thirds concerned with delegating, one third concerned with logic.

If a test specified logic then that's great because there's nothing easier to test than passing in a couple values and getting one back.
If a test specifies relationships then then that's good because I have some sort of evidence that the design is being validated that things are easy and simple to use.
But if a test specifies both logic and a relationship I feel no safety whatsoever. Im just bracing for the pain of a hard to maintain test. 

Mocked dependencies?
- These tests do not specify logic. They specify relationships.
- How is this subject going to orchestrate this work across these three things that actually go and do the work.
- When the contract between the subject and the things the subject depends on changes that's when the test needs to change. 

What if the subject has both mocked dependencies and logic?
- Our code has mixed levels of abstraction.
- Two thirds of our subject under tests is concerned with delegating and one third is concerned with logic. This is a classical design smell and we just got to find out about it because we were mocking.
- Instead of having two thirds be delegation and one third be logic, just force the subject to be a pure delegator. Make the third thing be a dependency.

If a test specifies both logic and relationships then we are looking at a hard to maintain test.

> Functions should either *do* or *delegate* but never both.

Isolated Unit Test?
- If an isolated unit test then you always want to mock out the direct dependency because this test will specify the contract that the subject has with the dependency. Moreover, the test data that you need is going to be absolutely minimal to just exercise the behaviore in the subject that you're concerned with.
- If you are trying to get regression safety and make sure "the thing works", then you either want to keep everything realistic or stay as far away as possible. At the HTTP layer you can save off JSON fixtures because those fixtures can have some kind of meaning later on if anything changes. However, what you do not want to do is pick some arbitrary depth in the stack and mock that out.

At the mocked layer:
- if the test has a direct dependency and this test fails, then this is a good thing because the failure means that our contract changed and we need to go and inspect that.
- if the mocked layer is an external system and it blows up, it's another good failure because it's the start of a conversation about how this API's contract is changing underneath us.
- if the mocked layer is the intermediate layer, it's just another form of useless pain. You learn nothing through the exercise.

> We can't defend the vaule of our tests if they fail for reasons that don't mean anything and must change in ways we can't anticipate.
- Justin Searls

Using mocks in tests of existing code
- Mocks replace a dependency of the subject that does part of the work that the subject delegates to. Values should be really cheap an easy to instantiate free of side effeects. 
- If your values are hard to isntantiate just make them better. Don't just punch a hole in them and mock them out.
- If you know your design has problems -- if you are living in a broken poorly designed house -- what more can a unit test tell you?
- If you are looking for safety, odds are you are writing tests so that you can have refactor safety. You need to get further away from the blast radius of that code -- increase your distance.
  - Go create a test that runs in a separate process but then invokes the code the same way a real user would, like, sending a post request. 
  - Then you can probably rely on it going and talking to some data store of something and after you've triggered the behavior that you want to observe, maybe you can interrogate it with additional HTTP requests, or maybe you can go and look at the SQL directly. 
  - However, this provides a much more reliable way for creating a safety net to go and aggressively refactor that problematic subject. This is an integration test. 
  - Integration tests are slower, finickier, they're a scam in the sense that if you write only integration tests your build duration will grow in a super linear rate and eventually become an albatross killing the team. However, they do provide refactor safety. 
  - Therefore, in the short and medium term if that's what you need, that's great. Plus they are more bang for your buck anyway. When you don't have a lot of tests you'll get a lot of coverage out of the gate.
- If isolated unit tests won't inform your design, don't bother with them.


People use tests to facilitate overly layered architectures. People who write a lot of tests are pushed to writing smaller things. Instead of one horse size duck we have a hundred duck size horses. Big is bad, but smaller isn't better because it's smaller. The code has to be focused in addition to being small.

Layering does not equal abstration, thoughtful design of a system.

The whole purpose of using mock objects is to write isolated unit tests to arrive at better designs. It was not to just fake out a database.

> If a test inflicts pain, people tend to blame the test -- even when the root cause is in the code's design. Hard to test code is hard to use code.
- Justin Searls.


The Good Way: The London School Of Test Driven Development -- based on a book by Nat Pryce and Steve Freeman, Growing Object Oriented Software Guided by Tests
- Outside in test driven development
- Discovery testing

I'm an anxious, panicky person.
Blank page syndrome - fear.
Uncertain designs.
Doubt

Ease
Confident
Doubt



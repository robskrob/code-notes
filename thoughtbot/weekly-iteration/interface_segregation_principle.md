# Interface Segragation Principle (ISP)

#thoughtbot

- finished watching

Definition: Clients should not be forced to depend on methods that they do not use.

In Rails we have arrays and ActiveRecord Relation. It's easy to mix these two collections together, which imposes complexity on the callers of these collections. When they think they just have an array -- they do not.

When we have clients that expect a huge interface then it will tend to break because clients tend to use whatever they can get at their disposal. The callers of your code are hooking dependencies into you. If your API either changes or does not provide enough methods the client will break.

### Eager loading

Where should the concern of Eager Loading be?

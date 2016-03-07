[&lt;&lt; Back to the README](README.md)

*Pulled from Chapter 9, "Designing Cost-Effective Tests"*

**Incoming messages should be tested for the state they return. Outgoing command
messages should be tested to ensure they get sent. Outgoing query messages
should not be tested.**

It's also better for tests to assume a viewpoint that sights along the edges
of the object under tests, where they can know only about the messages that
come and go; they should know nothing internal about the object under test.


## Creating Test Doubles

A fake object is called a *test double*. You can use one to play a role, when
necessary. It is a stylized instance of a role player that is used exclusively
for testing. They can be easy to make; nothing hinders you from creating one
for each situation.

Doubles can *stub* methods, to implement a version of a message that returns a
canned answer.

For simple test doubles, don't be afraid to use a PORO. You don't need to use
the provided test framework's instance, unless there is an added benefit.



[&lt;&lt; Back to the README](README.md)

*Pulled from Chapter 9, "Designing Cost-Effective Tests"*

**Incoming messages should be tested for the state they return. Outgoing command
messages should be tested to ensure they get sent. Outgoing query messages
should not be tested.**

It's also better for tests to assume a viewpoint that sights along the edges
of the object under tests, where they can know only about the messages that
come and go; they should know nothing internal about the object under test.

## Injecting Dependencies Using Classes

**When the code in your test uses the same collaborating objects as the code in
your application, your tests always break when they should. This can't be
emphasized enough.**

### Injecting Dependencies as Roles

#### Creating Test Doubles

A fake object is called a *test double*. You can use one to play a role, when
necessary. It is a stylized instance of a role player that is used exclusively
for testing. They can be easy to make; nothing hinders you from creating one
for each situation.

Doubles can *stub* methods, to implement a version of a message that returns a
canned answer.

For simple test doubles, don't be afraid to use a PORO. You don't need to use
the provided test framework's instance, unless there is an added benefit.

## Choosing to Test a Private Method

If you create a mess and never fix it your costs will eventually go up, but for
the roght problem, having enough confidence to write embarrassing code can save
money. **When your intention is to defer a design decision, do the simplest
thing that solves today's problem. Isolate the code behind the best interface
you can conceive and hunker down and wait for more info.**

Rules-of-thumb for testing private methods: Never write them, and if you do,
never ever test them, unless of course it makes sense to do so. Be biased against
writing these tests but do not fear to do so if this would improve your lot.

## Testing Outgoing Messages

Two types of outgoing messages: *query* and *command*.

### Ignoring Query Messages

Tests should ignore outgoing query messages. They should be tested as incoming
messages from the corresponding object's tests.

### Proving Command Messages

In this case, it does matter that a message gets sent; other parts of the app
depend on something that happens as a result. The object under test is
responsible for sending the message and your tests must prove it does so.

**The responsibility for testing a message's return value lies with its
receiver. Doing so anywhere else duplicates tests and raises costs.**

To prove that a message gets sent from the object under test to another
object, without relying on checking what comes back when it does, you need to
use a *mock*. **Mocks** are tests of behavior, as opposed to tests of state.
**Instead of making assertions about what a message returns, mocks define an
expectation that a message will get sent.**

**Mocks are meant to prove messages get sent, they return results only when
necessary to get tests to run.**



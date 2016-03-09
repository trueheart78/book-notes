[&lt;&lt; Back to the README](README.md)

# Chapter 9. Designing Cost-Effective Tests

Writing changeable code is an art whose practice relies on three different skills.

First, you must understand object-oriented design. Poorly designed code is
naturally difficult to change. From a practical point of view, changeability is
the only design metric that matters; code that's easy to change *is* well-
designed.

Second, you must be skilled at refactoring code. And not just casually.

>  Refactoring is the process of changing a software system in such a way that
   it does not alter the external behavior of the code yet improves the internal
   structure. - Martin Fowler

Key phrase: **does not alter the external behavior of the code.**

New features will be added only after you have successfully refactored the code.
Refactoring is how you morph the current code structure into one that fits new
requirements, and is core to OOD.

If your refactoring skills are weak, improve them. Design efforts will pay full
dividends only when you can refactor with ease.

Finally, the art of writing changeable code requires the ability to write high-
value tests. Tests give you confidence to refactor constantly. Efficient tests
prove that altered code continues to behave correctly without raising overall
costs.

Well-designed code is easy to change, refactoring is how you change from one
design to the next, and tests free you to refactor with impunity.

## Intentional Testing

The true purpose of testing, just like the true purpose of design, is to reduce
costs.

Those new to testing often find themselves unhappy that the tests they write *do*
cost more than the value those tetss provide, and generally argue about the worth
of tests.

Instead of abandoning tests because you don't think they are worthwhile, do the
work and get better at it.

### Knowing Your Intentions

#### Finding Bugs

Finding issues before they really become issues, early in the development process,
is very cost-effective. It always lowers costs.

#### Supplying Documentation

Tests provide the only reliable documentation of design. **Write your tests as
if you expect your future self to have amnesia.** You will forget; write tests
  that remind you of the story once you have.

#### Deferring Design Decisions

Tests allow you to safely defer design decisions. 

When your tests depend on interfaces you can refactor the underlying code with
reckless abandon. Intentionally depending on interfaces allows you to use tests
to put off design decisions safely and without penalty.

#### Supporting Abstractions

Good design naturally progresses toward small independent objects that rely on
abstractions.

As the code base expands and the number of abstractions grows, tests become
increasingly necessary. Tests are your record of the interface of every
abstraction and as such they are the wall at your back. They let you put off
design decisions and create abstractions to any useful depth.

#### Exposing Design Flaws

Another benefit of tests is that they expose design flaws in the underlying
code.  **If a test requires painful setup, the code expects too much context.**
If testing one object drags a bunch of others into the mix, the code has too
many dependencies. If the test is hard to write, other objects will find the
code difficult to reuse.

**Tests are the canary in the coal mine; when the design is bad, testing is hard.**

For tests to lower your costs, both the app *and* the tests must be well-
designed.

Your goal is to gain all the benefits of testing for the least cost possible.
The best way to achieve this goal is to write loosely coupled tests about only
the things that matter.

### Knowing What to Test

Most programmers write too many tests. **A simple way to get better value from
tests is to write fewer of them.** Test everything just once and in the proper
place.

Think of an OO app as a series of messags passing between a set of black boxes.
This will put constraints on what other objects are permitted to know and limits
public knowledge about any object to the messages that pierce its boundaries.

Well-designed objects have boundaries that are very strong. Nothing on the
outside can see in, nothing on the inside can see out and only a few explicitly
agreed upon messages can pass through.

**Willful ignorance of the internals of every other object is at the core of
design.** Dealing with objects as if they are only and exactly the messages to
which they respond lets you design a changeable application.

Tests should concentrate on the incoming or outgoing messages that cross an
object's boundaries.

Tests that make assertions about the values that messages return are tests of
*state*.

Objects should make assertions about state *only* for messages in their own
public interfaces.

Outgoing messages that are *queries* need not be tested by the sending object.

Outgoing messages that are *commands* do need to prove that they are properly
sent. This is a behavior test, not state, and involves assertions about the
number of times, and with what arguments, the message is sent.

**Incoming messages should be tested for the state they return. Outgoing command
messages should be tested to ensure they get sent. Outgoing query messages
should not be tested.**

As long as your application's objects deal with one another strictly via public
interfaces, your tests need know nothing more. As long as the public interfaces
remain stable, you can write tests once and they will keep you safe forever.

### Knowing When to Test

You should write tests first, whenever it makes sense to do so. Novice designers
sare best served by writing test-first code.

Writing tests first is no substitute for and does not guarantee a well-designed
application. The most complext code is usually written by the least qualified
person. Novice programmers don't yet have the skills to write simple code.

If you are a novice and in this situation, it's important to sustain faith in
the value of tests. Because well-designed apps are easy to change, and well-
designed tests may very well avoid change altogether, these overall design
improvements pay off dramatically.

Experienced designers garner subtler improvements from testing-first. Tests add
value in other ways.

"Spiking" a problem, where they just write code, are exploratory and for problems
whose solution they are uncertain. Once the design is understood, they revert to
test-first for production code.

The license to use your own judgment is not permission to skip testing. Poorly
designed code without tests is just legacy code that can't be tested.

### Knowing How to Test

Pick a testing suite; MiniTest and RSpec are both great choices.

Test Drive Development is an inside-out approach, while Behavior Driven Development
is an outside-in approach. The latter creates objects at the boundary of an app
and works inward, mocking out as-yet-unwritten objects. TDD usually starts with
tests of domain objects and then reuses said objects in the test of adjacent
layers of code.

There is no preference except personal preference.

Tests should know about the **object under tests**. They shouldn't know anything
else.

It's also better for tests to assume a viewpoint that sights along the edges
of the object under tests, where they can know only about the messages that
come and go; they should know nothing internal about the object under test.

## Testing Incoming Messages

Incoming messages need tests because other application objects depend on their
signatures and on the results they return. 

### Deleting Unused Interfaces

Incoming messages ought to have dependents. Some object *other than the original
implementer* depends on each of these messages.

If you find yourself with an incoming message that does not have dependents,
question it. What purpose is served by implementing a message that no one sends?
It's not really *incoming* at all, it's speculative and reeks about guessing
the future, anticipating requirements that don't exist.

**Do not test an incoming message that has no dependents; delete it.** Ruthlessly
eliminate code that is not actively being used. It's a negative cash flow,
adding tests and maintenance burdens without providing value. Deleting unused
code saves money right now, if you do not do so must test it.

**Overcome any relucatance that you feel; practicing deleting unused code will
teach you the value of such pruning.**

Regardless of whether you do it with joy or in pain, delete the code. Unused
code costs more to keep than to recover.

### Proving the Public Interface

Incoming messages are tested by making assertions about the value, or state,
that their invocation returns. The first requirement for testing an incoming
message is to prove that it returns the correct value in every possible
situation.

Tests run fastest when they execute the least code and the volume of external
code that test invokes is directly related to your design.

Tests are harbingers of things to come for your application as a whole.

### Isolating the Object Under Test

Freeing your imagination from an attachment to the class of the incoming object
opens design *and testing* possibilities that are otherwise unavailable. Think
of an injected object as an instance of its role and you will have more choices
about what kind of object to inject during your tests.

### Injecting Dependencies Using Classes

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

*Tes doubles* are *not* mocks; those are something completely different and will
be discussed later on.

#### Living the Dream

You can get false positives if you use test doubles to implement public interfaces,
but then the public interface changes but the test double and object under test
do not.

#### Using Tests to Document Roles

When remembering that a role even exists is a challenge, forgetting that test
doubles play it is inevitable.

Roles need tests of their own.

Injecting doubles can speed tests but leave them vulnerable to constructing a
fantasy world where tests work but the application fails. And injecting the
same objects at test time as are used at runtime ensures that tests break
correctly but may lead to long running tests.

Reducing object coupling is up to you and relies on your understanding of the
principles of design.

## Testing Private Methods

Testing private methods is never necessary. Issues should arise from the testing
of public methods that already have tests. These tests are redundant.

Private methods are also unstable, so tests are likely to be coupled to code
that is likely to change.

Testing private methods can mislead others into using them. Your tests should
hide private methods, not expose them.

### Removing Private Methods from the Class Under Test

You can avoid private methods altogether.

If your object has so many private methods that you dare not leave them untested,
consider extracting them into a new object.

However, methods don't become magically more reliable just because they got
moved.

### Choosing to Test a Private Method

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

In a well-designed app, testing outgoing messages is simple. If you have
proactively injected dependencies, you can easily substitute mocks. Setting
expectations on these mocks allows you to prove that the object under test
fulfills its responsibilities without duplicating assertions that belong
elsewhere.

## Testing Duck Types

Creating tests that role players can share and returning to the original problem
and uses shareable tests to prevent test doubles from becoming obsolete.

### Testing Roles

If you run into code that uses the antipatter of class checking to know which
message to send, consider refactoring to a better design before writing tests.
It's a rare case that this is the recommended course of action, but with the
code being so fragile, this is the one time.

You first need to decide on the proper role's interface and implement that in
every player of the role.

Your tests should document the existence of the role, prove each of the classes
that play the role behave correctly, and show that the interaction with them
appropriately.

Used sharable tests to assert that the class responds to the public interface
for the role, and include the tests in all the relevant classes.

In MiniTest, you can define the interface test as a module, alllowing you to
write the test once and then reuse it in every object that plays the role. The
module serves as a test and as documentation. It raises the visibility of the
role and makes it easy to prove that any created role player fulfills its
obligations.

For the classes that need to verify the message is sent to the role, use a mock
to verify that it is sent properly. If more than a single class depends on
talking to the role players, then consider moving the mock-based test into a
module to share the test code.

### Using Role Tests to Validate Doubles

In the instance where test doubles can cause tests to pass, even though the
public interface of the real class has changed, you should use a shared role
test against the test double, guaranteeing that a false positive will happen,
and raising the chance that your tests will catch breakages.

When you treat test doubles as you would any other role player and test them to
prove their correctness, you avoid test brittleness and can stub without fear
of consequence.

## Testing Inherited Code




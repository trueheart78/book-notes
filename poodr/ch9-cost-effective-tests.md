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



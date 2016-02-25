[&lt;&lt; Back to the README](README.md)

# Chapter 4. Creating Flexible Interfaces

An OO app is more than just classes. It is made up of *classes* but **defined
by messages**. Classes control what's in your source code repo; messages
reflect the living, animated application.

The conversation between objects takes place using their interfaces.

## Understanding Interfaces

Exposed methods comprise the class's public interface.

This chapter addresses methods within a class and how and what to expose to
other classes.

## Defining Interfaces

A class is like a kitchen. It exists to fulfill a single responsibility but
implements many methods. Some represent the menu and should be public, others
deal with internal implementation details and are private.

### Public Interfaces

- Reveal its primary responsibility
- Are expected to be invoked by others
- Will not change on a whim
- Are safe for others to depend on
- Are thoroughly documented in the tests

### Private Interfaces

- Handle implementation details
- Are not expected to be sent by other objects
- Can change for any reason whatsoever
- Are unsafe for others to depend on
- May not even be referenced in the tests

### Responsibilities, Dependencies, and Interfaces

Public methods should read like a description of responsibilities. It is a contract
that articulates the responsibilities of your class.

The public parts of a class are the stable parts; the private parts are the changeable
parts.

## Finding the Public Interface

Finding and defining public interfaces is an art. There are no cut-and-dried rules.

Good public interfaces reduce the cost of unanticipated change; bad public interfaces
raise it.

### An Example Application: Bicycle Touring Company

#### Constructing an Intention

Getting started with the first bit of code in a new app is intimidating. **The design
that gets extended later is the one that you are establishing now.**

The reason that test-first gurus can easily start writing tests is that they have
so much design experience. They have a mental map of possibilities for objects
and interactions in the app. They are not attached to any specific idea and plan
to use tests to discover alternatives. They do have an intention about the app,
and that intention allows them to specify the first test.

A class that has both **data** and **behavior** is a **domain object**. They are
obvious because they are persistent. Customer, Trip, etc. They have db-backed
classes.

Domain objects are a trap for the unwary. If you fixate on them, you will tend
to coerce behavior into them. Notice them, but do not concentrate on them.
**Focus not on these objects but on the messages that pass between them**.

#### Using Sequence Diagrams

Sequence diagrams are defined in the Unified Modeling Language (UML).

Do not reinvent this wheel; use what exists.

They provide a simple way to experiment with different object arrangements and
message passing schemes. They are a lightweight way to acquire intention about
interaction.

Draw them on a whiteboard, alter them as needed, and erase them when they've
served their purpose.

The main parts of a sequence diagram are **objects** and the **messages** passing
between them. 

*"Should this receiver be responsible for responding to this message?"*

Using a sequence diagram, the conversation shifts from classes and what they knew,
instead it now revolves around messages. You are deciding on a message and figuring
out where to send it.

Transitioning from a class-based design to message-based design is a turning point
in a design career. It yields more flexible apps than does the class-based
perspective. *"I need to send this message, who should respond to it?"* trumps
*"I know I need this class, what should it do?"*.

You don't send messages because you have objects, you have objects because you
send messages.

### Asking for "What" Instead of Telling How

There is a distinction between a message that asks for what the sender wants and
a message that tells the receiver how to behave. Understanding this difference
is a key part of creating reusable classes with well-defined public interfaces.

### Seeking Context Independence

An object can have a single responsibility but expects a context. If you are not
careful, this can breed coupling.

**The context that an object expects has a direct effect on how difficult it is to
reuse.**

Objects that have a simple context are easy to use and easy to test; they expect
few things from their surroundings.

The best possible situation is for an object to be completely independent of its
context. An object that could collaborate with others without knowing who they
are or what they do could be reused in novel and unanticipated ways.

**What** an object wants from another should help guide you to see that **how**
it wants it doesn't matter, and should be part of a separate object. Think
dependency injection.

### Trusting Other Objects

An object should be able to say **"I know what I want and I trust you to do your
part."** It should not know how it is done, or what the other object does. It
only matters that it responds to the message that needs to be sent.

Blind trust is a keystone of OOD. It allows objects to collaborate without
binding themselves to context is necessary in any app that expects to grow and
change.

### Using Messages to Discover Objects

Often times, you will find yourself needing an as yet undefined object, and
this can happen via many routes. Using sequence diagrams makes this more likely
to happen when it is cheapest; earliest in the design.

### Creating a Message-Based Application

Sequence diagrams can be helpful, but there are other methods. By switching
your attention from objects to messages allows you to concentrate on designing
an app built up public interfaces.

## Writing Code That Puts Its Best (Inter)Face Forward

The clarity of your interfaces reveals your design skills and reflects your
self-discipline. However, it is difficult to create perfect interfaces.

You should still try, though.

**Think** about interfaces. Create them intentionally. They will define your
app and determine its future, more than all of your tests and any of your code.

### Create Explicit Interfaces

Every time you create a class, declare its interfaces. Methods in the **public**
interface should

+ Be explicitly defined as such
+ Be more about **what** than **how**.
+ Have names that, insofar as you can anticipate, will not change.
+ Uses named parameters.

**Be just as intentional about the private interface; make it inescapably
obvious**. Tests should support this endeavor.

Know the different use-cases for `public`, `protected`, and `private`.

1. They indicate which methods are stable and which are unstabe.
2. They control how visible a method is to other parts of your app.

Private: Only callable from inside the object. Unstable.

Protected: Like private, but for sub-classes too? Kinda unstable.

Public: Everyone has access. Stable.

Consider using a leading underscore for private methods, a la Rails.

Choose to convey the method visibility, regardless of exactly how.

### Honor the Public Interfaces of Others

Do your best to interact with other classes using only their public interfaces.

If your design forces the use of a private method in another class, rethink
your design.

A dependenvy on a private method of an external framework is a form of technical
debt. Avoid these dependencies.

### Exercise Caution When Depending on Private Interfaces

Despite your best efforts, you may find that you **must** depend on a private
interface. *This is very dangerous*. If you must, be sure to isolate this
dependency.

### Minimize Context

Construct public interfaces with an eye toward minimizing the context they
require from others. Keep the **what** versus **how** distinction in mind; create
public methods that allow senders to get what they want without knowing how
your class implements its behavior.

Do not succumb to a class that has an ill-defined or absent public interface.
*Even if the original author did not define a public interface it is not too
late to create one for yourself.*

Do what best suits your needs, but create some kind of defined public interface
and use it.

## The Law of Demeter

A set of coding rules that results in loosely coupled objects.

### Defining Demeter

Avoid sending messages to a thid object via a second object of a different type.
**"Only talk to your immediate neighbor"** or **"use only one dot."**

`customer.bicycle.wheel.tire`
`hash.keys.sort.join(', ')`

These are called *trainwrecks*, as they mimic a train car and the dots are the
connections between them.

### Consequences of Violations

A "law" because a human being decided so; don't be fooled by its grandiose name.
It's more like "floss your teeth every day" than it is like gravity.

TRUE: transparent, reasonable, usable, and exemplary

Due to type-checking, the line `hash.keys.sort.join(', ')` is a minor violation
that has more payoffs than if you were to break it apart, where it would cost
a more overall.

The Law of Demeter exists *in service of* your overall goals.

### Avoiding Violations

Delegations are an option, either via Rails keywords or a wrapper method in Ruby.

Careful, however, because using delegation can result in code that obeys the
letter of the law while ignoring its spirit. Hiding tight coupling is not the
same as decoupling the code.

### Listening to Demeter

Demeter is trying to tell you something and it isn't "use more delegation."

The train wrecks of Demeter violations are clues that there are objects whose
public interfaces are lacking. Listening to Demeter means paying attention to
your point of view. The messages you find will become public interfaces in the
objects they lead you to discover.

## Summary

Focusing on messages reveals objects that might otherwise be verlooked. When
messages are trusting and ask for what the sender wants instead of how to
behave, objects naturally evolve public inerfaces that are flexible and reusable
in novel and unexpected ways.

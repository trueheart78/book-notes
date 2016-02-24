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



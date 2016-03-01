[&lt;&lt; Back to the README](README.md)

# Chapter 5. Reducing Costs with Duck Typing

Duck types are public interfaces that are not tied to any specific class.

Duck typed objects are chameleons that are defined more by their behavior than
their class.

## Understanding Duck Typing

An object can implement many different interfaces.

Users of an object need not, and should not, be concerned about its class.

It's not what an object *is* that matters, it's what it *does*.

If every object trusts all others to be what it expects at any given moment,
and any object can be any kind of thing, the design possibilities are infinite.

Using this flexibility wisely requires that you recognize these across-class
types and construct their public interfaces intelligently and dilligently.

### Overlooking the Duck

### Compounding the Problem

If your design imagination is constrained by class and you find yourself
dealing with objects that don't understand the message you are sending, your
tendency is to go hunt for messages these new objects **do** understand.

If you send messages they understand that are not common, you are now checking
classes and sending specific arguments to each. A case statement for class
checking solves the problem of sending the correct messages but bloats the
dependencies by a landslide.

This code then introduces this pattern, causing the application design to suffer
for the rest of eternity.

### Finding the Duck

Every argument is here for the same reason and that reason is unrelated to the
argument's underlying class.

Avoid getting sidetracked by your knowledge of what each argument's class already
does; think instead about what the current method needs.

Finding the common role becomes important, as each class needs to understand the
correct message.

## Conseqeunces of Duck Typing

Getting to duck typing can take you through the quagmires of adversity.

Concrete code is easy to understand but costly to extend.

Abstract code may initially seem more obscure but, once understood, is far easier
to change.

The ability to tolerate ambiquity about the class of an object is the hallmark
of a confident designer. Once you begin to treat your objects as if they are
defined by their behavior rather than by their class, you enter into a new realm
of expressive flexible design.

**Polymorphism** in OOP refers to the ability of many different objects to respond
to the same message. They agree to be interchangeable *from the sender's point of
view*.

## Writing Code That Relies on Ducks

Recognize places where your application would benefit from across-class interfaces.

Easy to implement, generally, but can be tricky to notice you need once and to
abstract its interface.

### Recognizing Hidden Ducks

Look for

- Case statements that switch on class
- `kind_of?` and `is_a?`
- `responds_to?`

### Placing Trust in Your Ducks

`kind_of?`, `is_a?`, `responds_to?` and `case` statements that switch on your
classes indeicate the presence of an unidentified duck. In each case the code
is effectively saying, "I know who you are and because of that **I know what
you do.**" 

The style of code is an indication that you are missing an object, one whose
public interface you have not yet discovered.

Flexible apps are built on objects that operate on trust; it is your job to
make your objects trustworthy. Use the offending code's expectation to find
the duck type, then define the interface, and trust those implementers to
behave correctly.

### Documenting Duck Types

The simplest kind of duck type is one that exists merely as an agreement about
its public interface.

**When you create duck types you must both document and test their public
interfaces.** Fortunately, good tests are the best documentation.

### Sharing Code Between Ducks

Once you start using duck types, you'll find that classes that implement them
often need to share some behavior. Sharing code comes as part of
[Chapter 7 on Modules](ch7-behavior-thru-modules.md).

### Choosing Your Ducks Wisely

Creating a new duck type relies on judgement. The purpose of design is to lower
costs; bring this measuring stick to every situation. If creating a duck type
would reduce unstable dependencies, do so. But some situations that use Ruby
standard library checks are ok, because they depend on very stable things.

**Avoid monkey patching to make duck typing a thing.**

## Conquering a Fear of Duck Typing

*skimmed, as per the book's suggestion*

Programmers who fear dynamic typing tend to check the classes of objects in
their code; these very checks subvert the power of dynamic typing, making it
impossible to use duck types.

More class checks = less flexible code.

Duck typing provides a way out of this trap. It removes the dependencies on
class and thus avoids the subsequent type failures. It reveals stable abstractions
on which your code can safely depend.

### Static vs Dynamic Typing

*skimmed*

### Embracing Dynamic Typing

When a dynamically typed application cannot be tuned to run quickly enough,
static typing is the alternative. **If you must, you must.**

Metaprogramming is a scalpel; though dangerous in the wrong hands, it's a tool
no good programmer should willingly be without.

**The code is only as good as your tests; runtime failures can still occur.**

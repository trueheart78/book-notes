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



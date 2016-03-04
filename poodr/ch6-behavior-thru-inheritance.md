[&lt;&lt; Back to the README](README.md)

# Chapter 6. Acquiring Behavior Through Inheritance

Well designed apps are constructed of reusable code. Small, trustworthy, self-
contained objects with minimal context, clear interfaces, and injected dependencies
are inherently reusable.

## Understanding Classical Inheritance

Inheritance is, ati its core, a mechanism for **automatic message delegation.**
It defines a forwarding path fir not-understood messages.

In class-based inheritance these relationships are defined by creating subclasses.

## Recognizing Where to Use Inheritance

### Starting with a Concrete Class

You might start with a `Bicycle` class that at first is used for road-based bikes.
Once a mountain bike enters the picture though, instead of building a completely
different class, or adding boolean checks to the existing, you should consider
if class-based inheritance is the right fit.

### Embedding Multiple Types

It is easy to extend a class to have more than one responsibility.

Look for **if statements** that check **attributes that hold a category of self**
to determine what message to send to **self**.

The class of an object is simple a specific case of an attribute that holds the
category of self.

### Finding the Embedded Types

Look for variables named `style`, `type`, or `cateogry`. These types of names
are your cute to notice the underlying pattern. What is a class if not a category
or type?

Inheritance solves the problem of highly related types that share common behavior
but differ along some dimension.

### Choosing Inheritance

No matter how complicated the code, the receiving object ultimately handles any
message in one of two ways:

1. It responds directly
2. It passes the message on to some other object for a response

Inheritance provides a way to define two objects as having a relationship such that
when the first receives a message that it does not understand, it *automatically* 
forwards, or delegates, the message to the second. It's as simple as that.

**Single inheritance** sidesteps the complications of *multiple inheritance*,
whereby a subclass is allowed only a single parent superclass.

Think of `NilClass.nil?` as it answers `true`, and `Object.nil?` as it is the
only other class to answer this question, and it does so with `false`.

The face that unknown messages get delegated up the superclass hierarchy implies
that subclasses are everything their superclasses are, plus **more**.

### Drawing Inheritance Relationships

You can use **UML class diagrams** to illustrate class relationships.

The hollow triangle means that the class inherits from said class.

![UML class diagram](poodr-6-4.png)

## Misapplying Inheritance

*skimmable*

## Finding the Abstraction

You can call `super` in a method that you are overriding when performing inheritance,
and call the original method. You can pass details, depend on class attributes, and
handle the return values.

Subclasses are **specializations** of their superclasses. A `MountainBike` should
be everything that a `Bicycle` is, plus more. Any object that expects a `Bicycle`
should be able to interact with a `MountainBike` in blissful ignorance of its
actual class.

### Creating an Abstract Superclass

The superclass should contain the common behavior, and the subclasses will add
specializations.

The superclass will represent an **abstract** class, one that is defined as being
disassociated from any specific instance.

Only good sense prevents other programmers from creating instances of the superclass;
in real life, this works remarkably well.

A superclass is an abstract class.

Abstract classes exist to be subclassed. This is their sole purpose.

It almost never makes sense to create an abstract superclass with only one subclass.

**Until you have a specific requirement that forces you to deal with other bikes,
the current class is good enough.**

Even when you have a requirement for two kinds of the same object, it **still**
may not be the right moment to commit to inheritance. There are costs involved;
the best way to minimize these costs is to maximize your chance of getting the
abstraction correct before allowing subclasses to depend on it. If 2 items provide
a lot of details, 3 provides even more.

A decision to proceed with the hierarchy for 2 objects accepts the risk that you
may not yet have enough info to identify the correct abstraction.

When creating an abstract class, rename the class being abstracted to be a subclass,
and create the abstraction against a new class.

Code is easier to promote up to a superclass than to demote it down to a subclass.

### Promoting Abstract Behavior

Don't completely re-implement `initialize` when you can simply add args and call
`super`.

You might be tempted to skip the middlemanand just leave the code in the superclass
to begin with, but this *push-everything-down-and-then-pull-some-things-up* strategy
is an important part of this refactoring. **Many of the difficulties of inheritance
are caused by a failure to rigorously separate the concrete from the abstract.**

Whan deciding between refactoring strategies, or between design strategies in
general, it is useful to ask the question: "What will happen if I am wrong?"

**Promotion failures thus have low consequences.**

The hierarchy can become untrustworthy if you use demotion-based superclassing.

**The consequences of a demotion failure can be widespread and severe.**

The general rule for refactoring into a new inheritance hierarchy is to arrange
code so that you can promote abstractions rather than demote concretions.

"What will happen *when* I'm wrong?" Every decision you make includes two costs:
one to implement it and another to change it when you discover that you were
wrong.

### Separating Abstract from Concrete

Sometimes, a concrete method will need to be broken up to make the abstract
parts available in the superclass while the specific implementations need to
stay in a subclass.

### Using the Template Method Pattern

Defining a basic structure in the superclass and sending messages to acquire
subclass-specific contributions is known as the **template method** pattern.

You might not need one for each attribute, just the attributes that need to be
overridden by subclasses.

A superclass can provide structure for its subclasses, where it permits them to
influence the algorithm, it sends messages. Subclasses contribute to the
algorithm by implementing matching methods.

### Implementing Every Template Method

Any class that uses the template method pattern must supply an implementation
for every message it sends, even if that implementation looks like this:

```ruby
class Bicycle
  def default_tire_size
    raise NotImplementedError
  end
end
```

This provides useful documentation for those who can be relied upon to read it,
and useful error messages for those that cannot.

You might even consider changing the above `raise` to

```
raise NotImplementedError, "This #{self.class} cannot respond to:"
```

This will make error messaages unambiquous and easily correctable.

Creating code that fails with reasonable error messages takes minor effor in
the present but provides value forever. Each error message is a small thing,
but small things accumulate to produce big effects and it is this attention to
detail that marks you as a serious programmer. **Always document template errors
by implementing matching methods that raise useful errors.**

## Managing Coupling Between Superclasses and Subclasses



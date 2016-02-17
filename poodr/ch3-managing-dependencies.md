[&lt;&lt; Back to the README](README.md)

# Chapter 3. Managing Dependencies

A single object cannot know everything, so inevitably it will have to talk to
another object.

Each message is initiated by an object to invoke some bit of behavior. So for
any desired behavior, an object either knows it personally, inherits it, or
knows another object who knows it.

SRP objects require that they collaborate to accomplish complex tasks. Knowing
creates a dependency, which can strangle your app if you don't manage them
carefully.

## Understanding Dependencies

An object depends on another if, when one of them changes, the other might be
forced to change in turn.

### Recognising Dependencies

An object has a dependency when it knows:

- the name of another class
- the name of a message that it intends to send to someone other than `self`
- the arguments that a message requires
- the order of those arguments

**Your design challenge is to manage dependencies so that each class has the
fewest possible; a class should know just enough to its job and not one thing
more.**

### Coupling Between Objects (CBO)

The more tightly couple two objects are, the more they behave like a single entity.

### Other Dependencies

Knowing the name of a message you plan to send to someone other than `self`.

Test-to-code over-coupling.

## Writing Loosely Coupled Code

Think of a dependency as a little dot of glue that causes your class to stick to
the things it touches. A few dots are necessary, but too much glue and your
application will harden into a solid block.

### Inject Dependencies



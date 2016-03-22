[&lt;&lt; Back to the README](README.md)

# Chapter 2. Performing Work

Is all of a method performing work? If some code isn't getting any work done, it
shouldn't be in the method at all, right?

The structure of the "work" portion of your code is determined based on what tasks
your methods are responsible for doing, and only you can say what those are. We
want to isolate the "core" of the method's logic.

It all starts with the idea of **sending messages**.

## Sending a Strong Message

*"The foundation of an object oriented system is the message"* - Sandi Metz, POODR

The fundamental feature of an OO program is the sending of messages. Every action
the program performs boils down to a series of messages sent to objects.

Think of a captain giving orders. A message should be sent, and we should trust
that it will be carried out.

To achieve this level of trust with your code, you need:

1. Identify the messages you want to send in order to accomplish the task at hand
2. Identify the **roles** which correspond to those messages
3. Ensure the method's logic receives objects that can play those roles

### Letting Language Be Constrained by the System

The practice of using objects to model logic is fundamentally about:

1. Identifying the messages we want to send
2. Determining the roles which make sense to receive those messages
3. Bridging the gap between the roles we've identified and the objects which
   actually exist in the system.

### Talk Like a Duck

**Roles** are names for *duck types*, simple interfaces that are not tied to any
specific class and are implemented by an object which responds to the right set
of messages.

Often, people fail to take the time to determine the kind of duck they really
need.

Also, the give up too early. Using `is_a?` and `respond_to?` are telltale signs,
as well as constantly checking variables to see if they are `nil` (another form
of type-checking).

When many `if` or `case` statements all switch on the value of the same attribute,
it's know as the *Switch Statements Smell`*. An object is trying to play the role
of more than one kind of duck.

### Herding Ducks

The way we martial inputs to a method has an outsize impact on the ability of that
method to tell a coherent, confident story.



# Terminology: Method versus Message

A "method" is defined on an object, and contains behavior. In the examples, the `Bottles` class
defines a method named `song`.

A "message" is sent by an object to invoke behavior. In the above example, the `song` method sends
the `verses` message to the implicit receiver `self`.

Therefore, methods are _defined_ and messages are _sent_.

Confusion about these comes about because it is common for the receiver of a message to define a
method whose name exactly corresponds to that message. Consider the example above. The `song`
methods sends the `verses` _message_ to `self`, which results in an invocation of the `verses`
_method_. The fact that the message name and method name are identical may make it seem as if the
terms are synonymous.

They are not.

Think of objects as black boxes. Methods are defined within a black box. Messages are passed between
them. There are many ways for an object to cheerfully respond to a message for which it does not
define a matching method. While it is common for message names to map directly to method names,
there isn't a requirement for this.

Drawing a distiction between messages and methods improves your OO mindset. It allows you to isolate
the intention of the sender from the implementation in the receiver. OO promises that if you send
the right message, the correct behavior will occur, regardless of the names of the methods that
eventually get invoked.

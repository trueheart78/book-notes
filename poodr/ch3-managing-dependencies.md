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



[&lt;&lt; Back to the README](README.md)

# Chapter 1. Rediscovering Simplicity

When you were new to programming you wrote simple code. You may not have appreciated
it at the time, but this was a great strength. Experience has brought you through
solving many complicated problems using increasingly complex solutions. You know
now that most code will someday change. Complexity seems both natural and inevitable.

Where you once optimized code for _understandability_, you now focus on its
_changeabilit_. It's less _concrete_ and more _abstract_. Things are harder to
understand in hopes that it will ultimately be easier to maintain.

This is the basic promise of Object-Oriented Design (OOD): that if you are willing
to accept increases in the complexity of your code along _some_ dimensions, you
will be rewarded with decreases in complexity along _others_. OOD doesn't claim
to be free; it merely asserts that its benefits outweigh its costs.

Design decisions ineveitably involve trade-offs. There's always a cost. For
example, if you've duplicated a bit of code in many places, the _Don't Repeat
Yourself_ (DRY) principle tells you to extract the duplicatation. DRY is a great
idea but it doesn't mean that it is free.

As you can see, design choices have costs, and they should only be paid if you
accrue some offsetting benefits. Design is thus about picking the right
abstractions.

However, abstractions are hard, and are easy to get wrong. You can't create the
right abstraction until you fully understand the code, but the existence of the
wrong abstraction may prevent you from ever doing so. So the goal is to **resist
the abstractions until they absolutely insist upon being created**.

This book is about finding the right abstraction.

## Simplifying Code

[&lt;&lt; Back to the README](README.md)

# Chapter 9. An Aside - What Are Types?

Lists and maps were talked about as types.

The first thing to understrand is that the primitive data types are not
necessarily the same as the types they can represent. A primitive Elixir list
is just an ordered group of values. We can use the [...] literal to create a
list, and the | operator to deconstruct and build lists.

Then there is the `List` module, which provides a set of fns that operate on
lists. Often these simply use recursion and the | operator to add the extra
functionality.

But there is a difference between the primitive list and the `List` module. One
is an implementation, while the other adds a layer of abstraction. Both
implement types, but the type is different. Primitive lists don't have things
like a `flatten` fn.

Maps are also a primitive type, and, like lists, they have an Elixir module
that implementes a richer, derived map type.

The `Keyword` type is actually a module, but it is implemented as a list of
tuples. While still a list, Elixir adds functionality to give you dictionary-
like behavior.

This is similar to duck typing in OOP. The `Keyword` module doesn't have an
underlying primitive data type, it simply assumes that any value it works on is
a list that has a certain structure.

This means the APIs for collections in Elixir are fairly broad.

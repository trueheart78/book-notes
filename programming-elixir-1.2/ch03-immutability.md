[&lt;&lt; Back to the README](README.md)

# Chapter 3. Immutability

Why does Elixir enforce immutable data?

## You Already Have (Some) Immutable Data

Let's talk Ruby.

```ruby
count = 99
do_something_with(count)
print(count)
```

Now, the `99` will not change. You trust that it won't, and would be surprised
if it did.

Now, if you allow pass-by-reference, it can get altered, and that can be a
nightmare. And you'd never be able to guarantee your code would procude the
correct results.

Now, arrays are pass-by-reference, meaning they can be changed.

Then, introduce multi-threading. It quickly snowballs into an oblivion gate.

## Immutable Data Is Known Data

Elixir sidesteps these problems, and thus all values are immutable. You can
rebind a variable, but you cannot mutate/change the value. This allows
concurrency sans nightmares (the best kind of concurrency, IMO).

Let's say you do need to increment each value of an array? Elixir does it by
producing a copy of the original, contain new values. And, the original is
unchanged, and no other code holding a reference to that original will be
affected.

## Perforamnce Implications of Immutability

This may seem to be an inefficient approach to programming. Let's look at that.

### Copying Data

Common sense might dictate that all this copying of data is inefficient, but
the reverse is true. Since this data won't change, it can be reused (in part,
or in whole) when biilding new structures.

### Garbage Collection

With a transformational language, old values tend to go unused when you create
new values from them, and this leaves memory on the heap for GC to reclaim.

With Elixir, each process has its own heap, and the data in your app is divided
up between these processes, so each heap is much, much smaller than if in a
single, shared heap. So GC is much faster.

## Coding with Immutable Data

Once you grasp the concept, coding with immutable data is quite easy. You just
have to remember that any function that transforms data will return a new copy
of it. So, we don't ever capitalize a string. Instead, we return a capitalized
copy of a string.

```elixir
name = "elixir"                    #=> "elixir"
cap_name = String.capitalize name  #=> "Elixir"
name                               #=> "elixir"
```

You might shivver at the `String.capitalize name` code, as in OO you would
expect `name.capitalize()`. However, the latter would modify the data, or,
it didn't, you wouldn't have any knowledge of what is happening, just
ambiquity.

In a functional language, **we always transform data. We never modify it in
place.**

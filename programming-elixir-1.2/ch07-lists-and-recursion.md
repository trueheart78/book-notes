[&lt;&lt; Back to the README](README.md)

# Chapter 7. Lists and Recursion

Recursion is a perfect tool for processing lists.

## Heads and Tails

A list may either be empty, or consist of a head and a tail. The head contains
a single value, and the tail itself is a list. This is a recursive definition.

So we'll represent the empty list like this: `[]`.

Now let's imagine that we could represent the split between the head and the
tail using a pipe char, `|`. 

```elixir
[3 | []]
```

So to the left of the pipe is what is considered the head, and to the right, the
tail.

So, let's look at a list of `[2, 3]`.

```elixir
[2 | [3 | []]]
```

You might think this isn't super useful, but you'd be wrong. Let's do
`[1, 2, 3]`

```elixir
[1 | [2 | [3 | []]]]
```

And this is valid Elixir syntax. You can totally type this into iex.

And remember that pattern matching also works in lists.

```elixir
[a, b, c] = [1, 2, 3]
#=> [1, 2, 3]
a
#=> 1
b
#=> 2
c
#=> 3
```

Let's use the pipe character and watch what happens when used in a pattern match:

```elixir
[head | tail] = [1, 2, 3]
#=> [1, 2, 3]
head
#=> 1
tail
#=> [2, 3]
```

**Note on iex:** There are "Strings" and there are 'lists' of printable chars,
notated by the double quote and single quote, respectively. For the latter, iex
isn't the brightest. If you enter `[99, 97, 116]`, you'll likely get a `cat` val
output to the screen. So be aware. This will be resolved later with some elbow
grease.

## Using Head and Tail to Process a List

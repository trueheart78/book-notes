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

WHy would lists come after modules and fns? Because lists and recursive fns go
together so very well.

- length of an empty list is 0
- length of a list is 1 + the length of the tail

```elixir
defmodule MyList do
  def len([], do: 0
  def len([head|tail]), do: 1 + len(tail)
end
```

The second match will match any non-empty list. When the tail is eventually
`[]`, then the recursion stops.

The above causes a compile warning, so we could change out `head` with `_`, or
we could use `_head`, which tells Elixir that the we are aware it may not be
used and to not warn us.

```elixir
defmodule MyList do
  def len([], do: 0
  def len([_head|tail]), do: 1 + len(tail)
end
```

## Using Head and Tail to Build a List

Now let's get ambitious by writing a fn that takes a list of numbers and
returns a new list containing the square of each.

```elixir
defmodule MyList do
  def square([]),            do: []
  def sqaure([head | tail]), do: [head*head | square(tail)]
end
```

When we match a non-empty list, we return a new list whose head is the square
of the head to the list passed int, and whose tail is a list of squares of the
tail. This is the recrusive beauty.

Now let's create a fn that adds 1 to every element in the list

```elixir
defmodule MyList do
  def add_1([]),            do: []
  def add_1([head | tail]), do: [head+1 | add_1(tail)]
end
```

## Creating a Map Function

Both the `square` and `add_1` share similar pattern matching, and use recursion
to call the same fn on the tail, while the head gets special treatment. We can
generalize this with a fn called `map` that takes a lits and an fn and returns
a new list with the result of applying that fn to each element.

```elixir
defmodule MyList do
  def map([], _func),            do: []
  def map([head | tail]), func), do: [func.(head) | map(tail, func)]
end
```

To call this fn:

```elixir
MyList.map [1, 2, 3, 4], fn (n) -> n*n end
#=> [1, 4, 9, 16]
```

A fn is just a built-in type, defined between `fn` and the `end`.

Now let's do the same, but using the `&` notation:

```elixir
MyList.map [1, 2, 3, 4], &(&1 + 1)
#=> [2, 3, 4, 5]
MyList.map [1, 2, 3, 4], &(&1 > 2)
#=> [false, false, true, true]
```

## Keeping Track of Values During Recursion

So let's say we want to sum a list, we'll need to track the total accumulative
value.

```elixir
defmodule MyList do
  def sum([], total),               do: total
  def sum([head | tail], total),    do: sum(tail, head+total)
end
```

Our `sum` fn now has two params, the list and the total so far.

The maintained *invariant* (a condition that is true on return from any call,
nested or otherwise) the sum of the elements in the list param plus the current
total will be equal to the total of the entire list.

We have to remember to pass the initial total, tho.

```elixir
MyList.sum([1, 2, 3, 4, 5], 0)
#=> 15
MyList.sum([11, 12, 13, 14, 15], 0)
#=> 65
```

Now, remembering to pass the first total can be tricky, so we define a single
public method that calls a private version, automatically providing it.

```elixir
defmodule MyList do
  def sum(list), do: _sum(list, 0)

  defp _sum([], total),            do: total
  defp _sum([head | tail], total), do: _sum(tail, head+total)
end
```

Notice that we use `defp` to define a private fn. These are not able to be
called from outside the module.

## Your Turn

Write the `sum` fn without using an accumulator. 

[Online solution from the author](https://forums.pragprog.com/forums/322/topics/Exercise:%20ListsAndRecursion-0):

```elixir
defmodule MyList do
  def sum1([]),              do: 0
  def sum1([ head | tail ]), do: head + sum1(tail)
end
```

### Generalizing Our Sum Function

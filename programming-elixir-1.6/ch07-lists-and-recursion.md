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

The sum fn reduces a collection to a single value, and this is not the only fn
that might need to do so (return the greatest/least, or the product, etc).

Let's generalize it to take a collection, as well as an initial value, and a fn
to apply.

```elixir
defmodule MyList do
  def reduce([], value, _) do
    value
  end
  def reduce([head | tail], value, func) do
    reduce(tail, func.(head, value), func)
  end
end

MyList.reduce([1, 2, 3, 4, 5], 0, &(&1 + &2))
#=> 15
MyList.reduce([1, 2, 3, 4, 5], 1, &(&1 * &2))
#=> 120
```

## Your Turn

1. Write a `mapsum` fn that takes a list and an fn, and applies the fn to each
   element of the list and sums the result. [Online Solution](https://forums.pragprog.com/forums/322/topics/Exercise:%20ListsAndRecursion-1)
2. Write a `max(list)` fn that returns the element with the max value in the
   list. [Online Solution](https://forums.pragprog.com/forums/322/topics/Exercise:%20ListsAndRecursion-2)
3. A single-quoted string is actually a list of character codes. Write a
   `caesar(list, n)` fn that adds `n` to each list element, wrapping if the
   addition results in a char greater than `z`. [Online Solution](https://forums.pragprog.com/forums/322/topics/Exercise:%20ListsAndRecursion-3)

**Solutions:**

```elixir
defmodule MyList do
  def mapsum([], _fun),            do: 0
  def mapsum([ head | tail ], fun), do: fun.(head) + mapsum(tail, fun)
end
```

```elixir
defmodule MyList do
  # max([]) is undefined...
  # max of a single element list is that element
  def max([x]), do: x
  # else recurse (Kernel.max/2 is called)
  def max([ head | tail ]), do: Kernel.max(head, max(tail))
end
```

```elixir
defmodule MyList do
  def caesar([], _n), do: []
  def caesar([ head | tail ], n)
    when head+n <= ?z,
    do: [ head+n | caesar(tail, n) ]
  def caesar([ head | tail ], n), 
    do: [ head+n-26 | caesar(tail, n) ]
end

IO.puts MyList.caesar('ryvkve', 13)
#=> elixir
```

## More Complex List Patterns

The join operator `|` supports more than a single item to the left, which makes
pattern matching even stronger.

```elixir
[1, 2, 3 | [4, 5, 6]]
#=> [1, 2, 3, 4, 5, 6]
```

```elixir
defmodule Swapper do
  def swap([]), do: []
  def swap([a, b | tail]), do: [b, a | swap(tail)]
  def swap([_]), do: raise "Can't swap a list with an odd number of elements."
end

Swapper.swap [1, 2, 3, 4, 5, 6]
#=> [2, 1, 4, 3, 6, 5]
Swappet.swap [1, 2, 3]
#=> ** (RunetimeError) Can't swap a list with an odd number of elements
```

The 3rd definition of `swap` matches a list with a single element, and this
match happens at the end of the recursion with a single element, thus causing
concern and raising an error.

### Lists of Lists

```elixir
defmodule WeatherHistory
  def for_location_27([]), do: []
  def for_location_27([ [time, 27, temp, rain] | tail) do
    [ [time, 27, temp, rain] | for_location_27(tail)]
  end
  def for_location_27([_ | tail]), do: for_location_27(tail)
end
```

This is a standard *recurse intil the list is empty* stanza. However, we are
also matching on an `head` where the second element of that list is `27`.

The third version also deals with the list when the pattern does not match.

Let's add some data.

```elixir
defmodule WeatherHistory
  def test_data do
    [
      [1366225622, 26, 15, 0.125],
      [1366225622, 27, 15, 0.45],
      [1366225622, 28, 21, 0.25],
      [1366229222, 26, 19, 0.081],
      [1366229222, 27, 17, 0.468],
      [1366229222, 28, 15, 0.60],
      [1366232822, 26, 22, 0.095],
      [1366232822, 27, 21, 0.05],
      [1366232822, 28, 24, 0.03],
      [1366236422, 26, 17, 0.025]
    ]
  end
end
```

Now let's see what happens.

```elixir
import WeatherHistory
for_location_27(test_data)
#=> [[1366225622, 27, 15, 0.45], [1366229222, 27, 17, 0.468], [1366232822, 27, 21, 0.05]]
```

Our fn is specific to a particular location. But with Elixir, we can even match
patterns within patterns.

```elixir
defmdule WeatherHistory do
  def for_location([], target_loc), do: []
  def for_location([head = [_, target_loc, _, _] | tail], target_loc), do
    [head | for_location(tail, target_loc)]
  end
  def for_location([_ | tail], target_loc), do: for_location(tail, target_loc)
end
```

The second definition adds a pattern match for the head itself, and require a
4-element array to be the head, with the second element being the `target_loc`.

## Your Turn

Write a function `MyList.span(from, to)` that returns a list of the numbers
from `from` up to `to`. [Online Solution](https://forums.pragprog.com/forums/322/topics/Exercise:%20ListsAndRecursion-4)

```elixir
defmodule MyList do
  def span(from, to) when from > to, do: []
  def span(from, to) do
    [ from | span(from+1, to) ]
  end
end
```

## The List Module in Action

Some key functions to know:

- `++`
- `List.flatten/2`
- `List.foldl/3`
- `List.foldr/3`
- `List.replace_at/3`
- `List.keyfind/3`
- `List.keyfind/4`
- `List.keydelete/3`
- `List.keyreplace/4`

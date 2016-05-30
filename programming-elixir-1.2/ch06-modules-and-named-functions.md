[&lt;&lt; Back to the README](README.md)

# Chapter 6. Modules and Named Functions

Once an app grows beyond a few lines, it ought to be structured. You do this by
creating *named functions* and organize these into **modules**. The prior
**have to be** written inside the latter.

```elixir
defmodule Times do
  def double(n) do
    n * 2
  end
end
```

A module named `Times` with a single fn, `double`. You will see this fn written
as `double/1`.

## Compiling a Module

You can compile this in two different manners:

```
iex times.exs
Times.double 4
#=> 8
```

Give iex a source file's name, and it compiles and loads the file before the
first prompt.

If you are already in iex, you can use the `c` helper to compile your file w/o
returning to the command line.

```elixir
c "times.exs"
#=> [Times]
Times.double(4)
#=> 8
```

The line `c "times.exs" compiles the source file and loads it into iex.

## The Function's Body Is a Block

The `do...end` block is one way of grouping expressions. However, `do...end` is
not the real syntax, it's actually:

```elixir
def doubl(n), do: n * 2
```

You can pass multiple lines to `do:` by grouping them with parens.

```elixir
def greet(greeting, name), do: (
  IO.puts greeting
  IO.puts "How are you doing, #{name}?"
)
```

The `do...end` is just a lump of syntactic sugar. It's actually just compiled
into the `do:` form. Generally, `do:` is used for single-line blocks, and
`do...end` is used for multiline ones.

So that `times` example would likely be:

```elixir
defmodule Times do
  def double(n), do: n * 2
end
```

It could even be more abridged by putting it all on a single line, but that is
only a headache for readers.

## Your Turn

1. Extend the `Times` module with a `triple` fn that multiples its params by 3.
2. Run the above result in iex and use both techniques to compile the file.
3. Add a `quadruple` function, and call the `double` fn from inside.

```elixir
defmodule Times
  def double(n), do: n * 2
  def triple(n), do: n * 3
  def quadruple(n), do: double(n) * 2
end
```

## Function Calls and Pattern Matching

When writing anon fns, pattern matching was done in a very `case`-ish manner.
With named fns, we move into writing the fn multiple times, each with its own
param list and body.

Think of the factorial of *n*, (written *n!*). If the factorial of 0 is checked
it is considered 1, the others have there own result. Elixir makes this simple.

```elixir
defmodule Factorial do
  def of(0), do: 1
  def of(n), do: n * of(n-1)
end
```

Here we have two definitions of the same fn, and it will try them in the order
they are defined, as long as the arity matches.

Tail recursion will help us improve this code later on. For now, let's play.

```elixir
c "factorial1.exs"
Factorial.of(3)
#=> 6
Factorial.of(7)
#=> 5040
Factorial.of(10)
#=> 3628800
Factorial.of(1000)
#=> 402387260077093...00000000
```

The one point worth stressing is the order of the clauses can make a difference
when you translate them into code. It tries fn from the top down, executing the
first match.

So don't do the following:

```elixir
defmodule Badfactorial do
  def of(n), do: n * of(n-1)
  def of(0), do: 1
end
```

The first will always match and the second will never be called. You will get
an error when attempting to compile this code, though.

Finally, make sure that multiple fn defs with the same name should be adjacent
in the source file.

## Your Turn

1. Implement and run a function `sum(n` that uses recursion to calculate the
   sum of integers from 1 to *n*.
2. Write a function `gcd(x,y)` that finds the greatest common divisor between
   two positive integers. And if `y` is zero, the return value should be `x`.
   Otherwise, it's `gcd(y, rem(x, y))`.

Solutions:

![ch06-maf-04-05](ch06-maf-04-05.png)

## Guard Clauses

Guard clauses allow you to distinquish pattern matching based on types, or a
test involving the param's value.

```elixir
defmodule Guard do
  def what_is(x) when is_number(x) do
    IO.puts "#{x} is a number"
  end
  def what_is(x) when is_list(x) do
    IO.puts "#{inspect(x)} is a list"
  end
  def what_is(x) when is_atom(x) do
    IO.puts "#{x} is an atom"
  end
end

Guard.what_is(99)         #=> 99 is a number
Guard.what_is(:cat)       #=> cat is an atom
Guard.what_is([1, 2, 3])  #=> [1, 2, 3] is a list
```

In the factorial example we did previously, if we passed in a negative number,
it would loop forever. 

```elixir
defmodule Factorial do
  def of(0), do: 1
  def of(n), do: n * of(n-1)
end
```

To fix this...

```elixir
defmodule Factorial do
  def of(0), do: 1
  def of(n) when n> 0 do
    n * of(n-1)
  end
end
```

Pattern matching won't find a fn to match against, and there will be an error
raised (FunctionClauseError).

### Guard-Clause Limitations

Only a certain subset of Elixir expressions in guard clauses. See the
[Getting Started Guide](http://elixir-lang.org/getting-started/case-cond-and-if.html#expressions-in-guard-clauses)

## Default Parameters

You define a default param with the `param \\ value` syntax, which changes how
pattern matching picks up your fn, as the number of required params is diff
than the number of allowed params. Params are matched left to right.

```elixir
defmodule Example do
  def func(p1, p2 \\ 2, p3 \\ 3, p4) do
    IO.inspect [p1, p2, p3, p4]
  end
end

Example.func("a", "b")            #=> ["a", 2, 3, "b"]
Example.func("a", "b", "c")       #=> ["a", "b", 3, "c"]
Example.func("a", "b", "c", "d")  #=> ["a", "b", "c", "d"]
```

Default args can behave surprisingly when Elixir does pattern matching:

```elixir
defmodule Example do
  def func(p1, p2 \\ 2, p3 \\ 3, p4) do
    IO.inspect [p1, p2, p3, p4]
  end

  def func(p1, p2) do
    IO.inspect [p1, p2]
  end
end
```

The above will not compile and provided a function conflict statement, as the
pattern matching would not know which fn to match to.

```elixir
defmodule DefaultParams1 do
  def func(p1, p2 \\ 132) do
    IO.inspect [p1, p2]
  end

  def func(p1, 99) do
    IP.puts "you said 99"
  end
end
```

The above will also have an issue compiling, complaing about needing a fn head
with the defaults.

```elixir
defmodule Params do
  def func(p1, p2 \\ 123)

  def func(p1, p2) when is_list(p1) do
    "You said #{p2} with a list"
  end

  def func(p1, p2) do
    "You passed in #{p1} and #{p2}"
  end
end


IO.puts Params.func(99)           # you passed in 99 and 123
IO.puts Params.func(99, "cat")    # you passed in 99 and cat
IO.puts Params.func([99])         # you said 123 with a list
IO.puts Params.func([99], "dog")  # you said dog with a list
```


## Your Turn

*I'm thinking of a number between 1 and 1000...*

Define a fn that will be `guess(actual, range)` where `range` is an Elixir
range.

Your ouutput should look similar to this:

```elixir
Chop.guess(273, 1..1000)
#=> Is it 500
#=> Is it 250
#=> Is it 375
#=> Is it 312
#=> Is it 281
#=> Is it 265
#=> Is it 273
#=> 273
```

Hints:

- Don't be afraid to implement helper fns
- The `div(a, b)` fn performs integer division
- Guard clauses are your friends
- Patterns can match the low and high parts of a range `(a..b=4.8)`

*Solution forthcoming - tired. You can see [solutions online](https://forums.pragprog.com/forums/322/topics/Exercise:%20ModulesAndFunctions-6)*

## Private Functions

The `defp` macro defines a private function - one that can only be called from
within the module that declares it.

You can also declare private fns with multiple heads, just like with `def`.
But they must all be private or public, not a mix thereof.

## The Amazing Pipe Operator: `|>`

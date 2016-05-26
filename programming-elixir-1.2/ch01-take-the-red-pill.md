[&lt;&lt; Back to the README](README.md)

# Chapter 1. Take the Red Pill

Elixir wraps functional programming with immutable state and an actor-based
approach to concurrency in a tidy, modern syntax. It even runs on the Erlang VM.

But why do we care?

Because you can stop worrying about many of the difficult things that currently
consume your time, like data consistency in a multi-threaded environment. Or
about scaling. And, most importantly, you can think about programming in a
different way.

## Programming Should Be About Transforming Data

When we code with objects, we're thinking about state. Class is king, and
our goal is data-hiding.

In the real world, however, we don't want to model abstract hierarchies, we just
want to get things done, not maintain state.

I don't want to hide data. I want to transform it.

### Combine Transformations with Pipelines

Unix users are used to the philosophy of small, focused command-line tools that
can be combined in arbitray ways.

This philosophy is incredibly flexible, leads to fantastic reuse, and is
highly reliable. A small program does one thing well, and that makes it easier
to test.

A command pipeline can also operate in parallel:

```sh
grep Elixir *.pml | wc -l
```

The word-count program `wc` runs at the same time as the `grep` command. Because
`wc` consumes `grep`'s output as it is produced, the answer is ready nearly as
soon as `grep` finishes.

Let's look at a simple Elixir function called `pmap`.

```elixir
defmodule Parallel do
  def pmap(collection, func) do
    collection
    |> Enum.map(&(Task.async(fn -> func.(&1) end)))
    |> Enum.map(&Task.await/1)
  end
end
```

We could run this function to get the squares of the numbers from 1 to 1000,
and it will kick off 1000 background processes.

```elixir
result = Parallel.pmap 1..1000, &(&1 * &1)
```

The code may not make much sense, but give it time. You'll be writing this kind
of thing for yourself.

### Functions Are Data Transformers

Elixir lets us solve the problem in the same way the Unix shell does. But,
instead of command-line utilities, we have functions, and we can string them
together as we please. The more focused the functions, the more flexible an
app we will have.

We can even make these functions run in parallel. Elixir has a simple but
powerful mechanism for passing messages between them. And these are not the
standard Unix processes and threads you may be used to, as you can run millions
of them on a single machine and have hundreds of these machines interoperating.

> "Most programmers treat threads and processes as a necessary eveil; Elixir
   developers feel they are an important simplification." - Bruce Tate

The idea of transformation is at the heart of functional programming: a function
transforms it inputs into its output.

But, this power comes at a price. A lot of what you know about programming will
need to be unlearned, and many of your instincts will be wrong. You must be okay
with being a n00b again (sometimes, that's part of the fun).

## Installing Elixir

This book assumes you are using Elixir 1.2+. See up-to-date instructions
available at [http://elixir-lang.org/install.html](http://elixir-lang.org/install.html)

## Running Elixir

### iex - Interactive Elixir

```sh
iex

Erlang/OTP 18 [erts-7.1] [source] [64-bit] [smp:4:4] [async-threads:10]
              [hipe] [kernel-poll:false] [dtrace]
Interactive Elixir (x.y.z) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)>
```

You can now enter Elixir code and see the result.

You can exit iex by `ctrl-c` twice, or `ctrl-g` followed by `q` and `return`.

### IEx Helpers

Type `h` in iex to see helpers available.

You will see a list of helper functions, and the number following the slash is
the number of args the helper expects.

You can even specify the module you want help on, like `h IO` or `h(IO)`, and
get help specifically on the module.

You can also specify the function you want help on, like `h IO.puts`, since we
will be using it to output a string to the console.

And, if you are used to using `p` in Ruby, try `i` in Elixir.

iex is a surprisingly powerful tool. You can use it to compile and execute
entire projects, log in to remote machines, and access running Elixir apps.

### Customizing iex

You can customize iex by setting options, like showing the results of evals
in a different collor.

```elixir
h IEx.configure
```

You can then create a `~/.iex.exs` with the following:

```elixir
IEx.configure colors: [ eval_result: [ :cyan, :bright ] ] 
```

If you have oddball stuff appearing in your terminal after this, disable the
colors:

```elixir
IEx.configure colors: [enabled: false]
```

**You can put an Elixir code into `.iex.exs`.**

## Compile and Run

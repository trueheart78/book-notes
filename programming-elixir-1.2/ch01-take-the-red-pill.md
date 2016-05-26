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

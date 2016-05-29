[&lt;&lt; Back to the README](README.md)

# Chapter 5. Anonymous Functions

Functions are a basic type in this functional language. You can create an anon
function using the `fn` keyword.

```elixir
fn
  parameter-list -> body
  parameter-list -> body ...
end
```

Think of `fn...end` as being like the quotes that surround a string literal,
except we're instead returning a function as a value (kind of like in
JavaScript and CoffeeScript). So we can also invoke it, and pass in args.

So the simplest form is a param list and a body, separated by `->`.

```elixir
sum = fn (a, b) -> a + b end
#=> Function<12.17052888 in :erl_val.expr/5>

sum.(1, 2)
#=> 3
```

Two invoke the function, the dot (`.`) is used, and the args are passed as
normal args would be.

Even if your function takes no args, you still need the parens to call it. But
you don't need the parens when defining the function.

```elixir
sum = fn a, b -> a + b end
#=> Function<12.17052888 in :erl_val.expr/5>

sum.(1, 2)
#=> 3

f2 = fn -> 99 end
#=> Function<12.17052888 in :erl_val.expr/5>

f2.()
#=> 99
```

## Functions and Pattern Matching

When we call `sum.(2,3)`, it's easy to assume we simply assign 2 to the param
`a` and `3` to be, but we're in a functional lang with immutable vars. Elixir
doesn't have assignment, it tries to match values to patters.

If we write `a = 2`, the Elixir makes the pattern match by binding `a` to the
value of `2`, which is what happens when our `sum` fn gets called. We pass `2`
and `3` as args, and Elixir tries to match them to the params `a` and `b`. It
would be the same if we wrote `{a, b} = {1, 2}`.

This means we can perform a more complex pattern match when we call a fn. For
example, the following fn reverses the order of elements in a two-element
tuple:

```elixir
swap = fn {a, b} -> {b, a} end
swap.({6, 8})
#=> {8, 6}
```

*Notice that the fn def has the variables in braces, as well as how they are
passed in. It looks like we can expect a tuple match on passing to be able to
work with the values inside the tuple without any extra magic.*

## Your Turn

Create functions in iex that will perform the following:

```elixir
list_concat.([:a, :b], [:c, :d])
#=> [:a, :b, :c, :d]
sum.(1, 2, 3)
#=> 6
pair_tuple_to_list.({1234, 5678})
#=> [1234, 5678]
```

My solutions:

![ch05-fn-01](ch05-fn-01.png)

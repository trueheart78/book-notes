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


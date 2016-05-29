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

## One Function, Multiple Bodies

A single fn def lets you define diff implementations, depending on the type and
contents of the args passed.

At its simplest, we can use pattern matching to select which clause to run. If
`File.open` has `:ok` as its first element when successfully opened, we can
write a fn that displays either the first line of said file or a simple error
message.

```elixir
handle_open = fn
                {:ok, file}  -> "Read data: #{IO.read(file, :line)}"
                {_,   error} -> "Error: #{:file.format_error(error)}"
              end

handle_open.(File.open("code/path"))
```

You'll notice that now, depending on what happens in the `File.open` call, a
different fn arg set gets matched on, changing the execution of the fn
altogether.

Also note that `:file.format_error` refers to the underlying Erlang `File`
module, so we can call its `format_error` fn.

## Working with Larger Code Examples

Remember that you can write out an `.exs` file and then load it into iex, and
iex will execute it and it's entirety. To do this, you must use the `c` fn, a
fn that compiles and runs the code in the given file.

```elixir
c "elixir_file.exs"
```

We can also run that file directly from the command line.

```sh
elxiir elixir_file.exs
```

Remember that `.exs` is used for source and script files, and `.ex` is used for
files we will want to compile and use later.

## Your Turn

Write a FizzBuzz fn that returns "FizzBuzz" if both args are zero, "Fizz" if
only the first is, and "Buzz" if only the second is. Return the third arg when
neither is zero.

Solution:

![ch05-fn-02](ch05-fn-02.png)

The operator `rem(a, b)` returns the remainder after dividing `a` by `b`.
Write a fn that takes a single integer (`n`), and calls the function from the
above exercise, passing it `rem(n, 3)`, `rem(n, 5)`, and `n`. Call it seven
times with arguments `10..16`. Expected output should be "Buzz, 11, Fizz, 13,
14, FizzBuzz, 16".

*And when you are complete, you will have written a FizzBuzz solution without
any conditional logic.*

Solution:

![ch05-fn-03](ch05-fn-03.png)

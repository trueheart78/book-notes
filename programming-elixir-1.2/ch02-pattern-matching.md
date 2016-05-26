[&lt;&lt; Back to the README](README.md)

# Chapter 2. Pattern Matching

Let's look at how assignment works in Elixir, cuz it's likely different from
what you know.

## Assignment: I Do Not Think It Means What You Think It Means

```elixir
a = 1  #=> 1
a + 3  #=> 4
```

Seems like simple addition in any 'ol programming language, but in Elixir, the
equals sign is not an assignment; it's like an assertion. It succeeds if Elixir
can find a way of making the left-hand side equal the right-hand side (like in
math class). Elixir calls `=` a **match operator**.

You might think the above code is just an assignment. Well, then:

```elixir
a = 1  #=> 1
1 = a  #=> 1
2 = a  #=> ** (MatchError) no match of right hand side value: 1
```

So the third line, `2 = a`, raises an error. And Elixir won't change values on
the right-hand side of a match, only the left.

## More Complex Matches

Elixir lists can be created using square brackets containing a comma-separated
set of values. Like in Ruby.

So, let's use some in matches:

```elixir
list = [1, 2, 3]  #=> [1, 2, 3]
```

To make the above match true, it bound the variable `list` to the list
`[1, 2, 3]`.

Some else, though?

```elixir
list = [1, 2, 3]  #=> [1, 2, 3]
[a, b, c] = list  #=> [1, 2, 3]
a  #=> 1
b  #=> 2
c  #=> 3
```

Elixir looks for a way to make the value on the left side the same as on the
right.

This process is called **pattern matching**. A pattern (the left side) is
matched if the values (the right side) have the same structure and if each term
in the pattern can be matched to the corresponding term in the values. A literal
value in the pattern matches that exact value, and a vairable in the pattern
matches by taking on the corresponding value.

More examples:

```elixir
list = [1, 2, [3, 4, 5]]  #=> [1, 2, [3, 4, 5]]
[a, b, c] = list          #=> [1, 2, [3, 4, 5]]
a                         #=> 1
b                         #=> 2
c                         #=> [3, 4, 5]
```

The value on the right side corresponding the term `c` on the left side is the
sublist, the value given to `c` to make the match true.

Here's some values and variables.

```elixir
list = [1, 2, 3]  #=> [1, 2, 3]
[a, 2, b] = list  #=> [1, 2, 3]
a                 #=> 1
b                 #=> 3
```

The literal 2 in the pattern matched the corresponding term on the right, so
the match succeeds. But if that wasn't a `2`, what would happen?

```elixir
list = [1, 2, 3]  #=> [1, 2, 3]
[a, 1, b] = list  #=> ** (MatchError) no match of right hand side value: [1, 2, 3]
```

The 1 cannot be matched against the corresponding element on the right side, so
no variables are set and the match fails.

## Your Turn

Exercise: PatternMatching-1

Which of the following will match? (assuming they are all run one after another)

- `a = [1, 2, 3]` **y**
- `a = 4` **y**
- `4 = a` **y**
- `[a,b] = [1, 2, 3]` **n**
- `a = [[1, 2, 3]]` **y**
- `[a]= [[1, 2, 3]]` **y**
- `[[a]] = [[1, 2, 3]]` **n**

## Ignoring a Value with _ (Underscore)

If we didn't need to capture a value during the match, we could use the special
variable `_` (an underscore). This acts like a variable but immediately
discards any value given to it. **It's basically a pattern matching wildcard**.

```elixir
[1, _, _] = [1, 2, 3]          #=> [1, 2, 3]
[1, _, _] = [1, "cat", "dog"]  #=> [1, "cat", "dog"]
```

## Variables Bind Once (per Match)

Once a var has been bound to a value in the matching process, it keeps that
value for the remainder of a match (*fight!*).

```elixir
[a, a] = [1, 1]  #=> [1, 1]
a                #=> 1
[a, a] = [1, 2]  #=> ** (MAtchError) no match of right hand side value: [1, 2]
```

The first expression succeeds because `a` is set to `1`, anf then it's checked 
against `1` immediately. You can probably see why it fails in the `[1, 2]`
assignment.

So let's get crazy: **a variable can be bound to a new value in a subsequent
match, and its current value does not matter**.

```elixir
a = 1                  #=> 1
[1, a, 3] = [1, 2, 3]  #=> [1, 2, 3]
a                      #=> 2
```

What if you want to force Elixir to use the existing value of the var in the
pattern? Give it a caret `^` (**the pin operator**).

```elixir
a = 1  #=> 1
a = 2  #=> 2
^a = 1 #=> ** (MatchError) no match of right hand side value: 1

a = 1                   #=> 1
[^a, 2, 3] = [1, 2, 3]  #=> [1, 2, 3]
a = 2                   #=> 2
[^a, 2] = [1, 2]        #=> ** (MatchError) no match of right hand side value: [1, 2]
```

The other important part of pattern matching will come up when we dig into
lists.


### Your Turn

Exercise: PatternMatching-2

Which of the following will match?

- `[a, b, a] = [1, 2, 3]` **no**
- `[a, b, a] = [1, 1, 2]` **no**
- `[a, b, a] = [1, 2, 1]` **yes**

Exercise: PatternMatching-3

The var `a` is bound to the value of `2` - which will match?

- `[a, b, a] = [1, 2, 3]` **no**
- `[a, b, a] = [1, 1, 2]` **no**
- `a = 1` **yes**
- `^a = 2` **yes**
- `^a = 1` **no**
- `^a = 2-a` **no**

## Another Way of Looking at the Equals Sign

Joe Armstrong, Erlang's creator, compares the equals sign in Erlang to that
used in algebar.

His point is that you had to unlear the algebraic meaning of `=` when you came
accrss assignment in imperative programming languages.

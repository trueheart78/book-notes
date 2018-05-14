[&lt;&lt; Back to the README](README.md)

# Chapter 4. Elixir Basics

Let's talk Elixir-specific stuff that you need to know.

## Built-in Types

- Value types:
  - Arbitrary-sized integers
  - Floating-point numbers
  - Atoms
  - Ranges
  - Regular expressions
- System types:
  - PIDs and ports
  - References
- Collection types:
  - Tuples
  - Lists
  - Maps
  - Binaries

Functions are also a type.

Notice no strings or structures. Elixir has them, but they are built using the
basic types from this list.

## Value Types

### Integers

Can be written as decimal (`1234`), hex (`0xcafe`), octal (`0o765`), and binary
(`0b1010`).

Decimal numbers may contain underscores, as in Ruby, so to make the reading of
large numbers easier (example: `1_000_000`).

There is no fixed limit on the size of integers.

### Floating-Point Numbers

Writtn using a decimal point, and there must be at least one digit on either
side of it. You can optionally provide a trailing exponent.

```elixir
1.0
0.2456
0.314159e1
314159.0e-5
```

Floats are IEE 754 double precision, with about 16 digits of accuracy and a max
exponent around 10 ** 308.

### Atoms

Atoms are like Ruby symbols, basically. An atom word is a sequence of letters,
digits, underscores, and `@` signs. It may even end with an exclamation point or
question mark.

```elixir
:fred
:is_binary?
:var@2
:<>
:===
:"func/3"
:"long john silver"
```

An atom's name is it's value, and two atoms with the same name will always be
equal, regardless of where they were created.

### Ranges

The `start..end` stuff, like in Ruby and CoffeeScript.

### Regular Expressions

Elixir has regex literals, written as `~r{regexp}` or `~r{regexp}opts`. You can
use any nonalphanumeric characters as delimiters (in place of the `{` and `}`),
as described in the discussion of sigils. Some people like `~r/.../` for
nostalgic reasons, but is less convenient since backslashes would need to be
escaped (unlike the cury-braces).

You manipulate regular expressions with the `Regex` module.

```elixir
Regex.run ~r{[aeiou]}, "caterpillar"          #=> ["a"]
Regex.scan ~r{[aeiou]}, "caterpillar"         #=> [["a"], ["e"], ["i"], ["o"], ["u"]]
Regex.split ~r{[aeiou]}, "caterpillar"        #=> ["c", "t", "rp", "ll", "r"]
Regex.replace ~r{[aeiou]}, "caterpillar", "*"  #=> "c*t*rp*ll*r"
```

## System Types

These reflect resources in the underlying Erlang VM

### PIDs and Ports

A PID is a reference to a process (local or remote), and a port is a reference
to a resource (typically an external one) that you'll be reading or writing.

The PID of the current process is available by calling `self`. A new PID is
created when you spawn a new process.

### References

The function `make_ref` creates a globally unique reference; no other reference
will be equal to it. It is not used in this book.

## Collection Types

So far, we've only seen common types (like arrays). Let's get exotic.

### Tuples

A tuple is an ordered collection of values.

You write a tuple between braces, separating the elements with commas.

```elixir
{1, 2}
{:ok, 42, "next"}
{:error, :enoent}
```

A typical Elixir tuple has two to four elements. For other sizes, consider maps
or structs.

You can use typles in pattern matching:

```elixir
{status, count, action} = {:ok, 42, "next"}    #=> {:ok, 42, "next"}
status                                         #=> :ok
count                                          #=> 42
action                                         #=> "next"
```

A common idiom is to write matches that assume success:

```elixir
{:ok, file} = File.open("Rakefile")        #=> {:ok, #PID<0.39.0>}
{:ok, file} = File.open("missing-file")    #=> ** (MatchError) .. {:error, :enoent}
```

You can see the first was good, and the second was not, and it produced an
error as the expected `:ok` was not matched.

### Lists

The literal syntax is pretty straightforward (`[,1,2,3]`), but don't let them
fool you. It's not like arrays in other languages. Instead, a list is a linked
data structure.

A list may be one of 2 things:

1. empty
2. consist of a head and a tail (the head is a value, the tail is a list)

The recursive definition of a list is at the core of a lot of Elixir
programming.

Lists are easy to traverse front-to-back, but randomly, they are expensive. It
is always cheap to get the head and extract the tail of a list.

And lists are immutable. So, if we want to remove the head and leave just the
tail, we never have to copy the list, because we can just return a pointer.

Some great list operators:

```elixir
[1, 2, 3] ++ [4, 5, 6]  #=> Concatenation [1, 2, 3, 4, 5, 6]
[1, 2, 3, 4] -- [2, 4]  #=> Difference    [1, 3]
1 in [1, 2, 3, 4]       #=> Membership    true
"wombat" in [1, 2, 3]   #=>               false
```

### Keyword Lists

Because we often need simple lists of key/value pairs, Elixir gives us a
shortcut.

```elixir
[ name: "Dave", city: "Dallas", likes: "Programming" ]
```

Well, Elixir converts what would otherwise be *almost* a Ruby hash into a list
of two-value truples:

```elixir
[ {:name, "Dave"}, {:city, "Dallas"}, {:likes, "Programming} ]
```

Elixir even alls us to leave off the square brackets if a keyword list is the
last arg in a function call (very Ruby-ish):

```elixir
DB.save record, [ {:use_transaction, true}, {:logging, "HIGH"} ]

# magic!

DB.save record, user_transaction: true, logging: "HIGH"
```

We can *also* leave off the brackets if a keyword list appears as the last item
in any context where a list of values is expected.

```elixir
[1, fred: 1, dave: 2]     #=> [1, {:fred, 1}, {:dave, 2}]
{1, fred: 1, dave: 2}     #=> {1, [fred: 1, dave: 2]}
```

## Maps

A map is a collection of key/value paurs, and a literal looks like:

```elixir
%{ key => value, key => value }
```

*(This seems a lot like a Ruby hash, btw)*

Here are some maps:

```elixir
states = %{ "AL" => "Alabama", "WI" => "Wisconsin" }
#=> %{"AL" => "Alabama", "WI" => "Wisconsin"}
responses = %{ {:error, :enoent} => :fatal, {:error, :busy} => :retry}
#=> %{{:error, :busy} => :retry, {:error, :enoent} => :fatal}
colors = %{:red => 0xff0000, :green => 0x00ff00, :blue => 0x0000ff}
#=> %{blue: 255, green: 65280, red: 16711680}
```

In the first case, the keys are strings, then they are tuples, and then they
are atoms. And the keys don't have to be of the same type, either.

If a key is an atom, you can use the same shortcut that you do with keyword
lists:

```elixir
colors = %{red: 0xff0000, green: 0x00ff00, blue: 0x0000ff}
#=> %{blue: 255, green: 65280, red: 16711680}
```

You can also use expressions for the keys in map literals:

```elixir
name = "Josh"
%{ String.downcase(name) => name }
#=> %{"josh" => "Josh"}
```

Why do we have both maps and keyword lists? Maps restrict each key to one
occurrence, and tend to be more efficient, as well as can be used in pattern
matching.

In general, use keyword list for stuff like command-line params and passing
options, and maps when you need an associative array.

### Accessing a Map

Classic hash:

```elixir
states = %{"ME" => "Maine"}
states["ME"]
#=> "Maine"

responses = %{ {:error, :enoent} => :fatal, {:error, :busy} => :retry}
responses[{:error, :busy}]
#=> :retry
```

And if you are using atoms for keys, you get access to dot notation:

```elixir
colors = %{:red => 0xff0000, :green => 0x00ff00, :blue => 0x0000ff}
colors[:red]
#=> 16711680
colors.green
#=> 65280
```

You will get a `KeyError` if there's no matching key when using the dot method.

### Binaries

Sometimes you need to access data as a sequence of bits and bytes. JPEG and MP3
files contain fields where a single byte may encode two or three separate
values.

Elixir supports this wuth the binary data type, enclosed between `<<` and `>>`.

The basic syntax packs successive integers into bytes:

```elixir
bin = << 1, 2 >>  #=> <<1, 2>>
byte_size bin     #=> 2
```

You can also add modifiers to control the type and size of each individual
field. Watch a single byte that contains three fields of widths 2, 4, and 2 bits.

```elixir
bin = <<3 :: size(2), 5 :: size(4), 1 :: size(2)>>
#=> 213
:io.format("~-8.2n~n", :binary.bin_to_list(bin))
#=> 11010101
#=> :ok
byte_size bin
#=> 1
```
Binaries are both important and arcane. Elixir uses them to represent UTF
strings, and (initially), you are unlikely to use them directly.

## Names, Source Files, Conventions, Operators, and So On

Source files are UTF-8, but identifiers may only use ASCII, and indentation is
not tab-based,but two-character spaced.

Comments? Those use the hash sign `#` and run to the end of the line.

There is a styleg guide writtn by the community, available at
[https://github.com/niftyn8/elixir_style_guide](https://github.com/niftyn8/elixir_style_guide). This may move in the future.

### Truth

Elixir has three special values related to Boolean operations, and they are the
same as in Ruby: `true`, `false`, and `nil`. All three of these values are
aliases for atoms of the sam name, so you could use `:true`, `:false`, and
`nil` to have the same affect. And **truthy** boils down to anything that is
not `false` or `nil` (both considered **falsey**).
`:false` and they will

### Operators

#### Comparison Operators

Here's a subset of operators covered in this material:

- `===` is for strict equality
- `!--` is for string inequality
- `==` is for value equality
- `!=` is for value inequality
- `>`, `>=`, `<`, `<=` are all for normal comparison

If the types are the same or compatible, the comparison uses natural ordering.
Otherwise, comparison is based on type in this manner.

> number < atom < reference < function < port < pid < tuble < map < list <
  binary

#### Boolean Operators

These perators expect `true` or `false` as their first argument

```elixir
a or b   # true if a is true, otherwise b
a and b  # false if a is fase, otherwise b
not a    # false if a is true, true otherwise
```

#### Relaxed Boolean Operators

These take arguments of any type.

```elixir
a || b  # a if a is truthy, otherwise b
a && b  # b if a is truthy, otherwise a
!a      # false if a is truthy, otherwise true
```

#### Arithmetic Operators

`+`, `-`, `*`, `/`, `div`, and `rem`

Integer division yields a floating point result. Use `div(a,b)` to get an int.

`rem` is the *remainder operator* and is called as a function:
`(rem(11,3) => 2)`. It differs from modulo operations in that the result will
have the same sign as the first arg.

#### Join Operators

```elixir
binary1 <> binary2  # concats two binaries.
list1 ++ list2      # concats two lists
list1 -- list2      # returns elements in list1 not in list2
```

#### The `in` Operator

```elixir
a in enum  # tests if a is included in enum (perhaps a list or a range)
```

## Variable Scope

Elixir is lexically scoped. Variables defined in a function are local to that
function. Modules define a scope for local vars, but are only accessible at the
top level of that module, and not in functions defined in said module.

Several Elixir structures als define their own scope, like `with` (and later,
`for`).

### The `with` Expression

The `with` expression serves double duty. It allows you define to a local scope
for variables.

```elixir
content = "Now is the time"

lp = with {:ok, file}   = File.open("/etc/passwd",
          content       = IO.read(file, :all),
          :ok           = File.close(file),
          [_, uid, gid] = Regex.run(~r/_lp:*.?:(\d+):(\d+)/, content)
     do
       "Group: #{gid}, User: #{uid}"
     end

IO.puts lp       #=> Group: 26, user: 26
IO.puts content  #=> Now is the time
```

The `with` expression lets us work with what are effectively temporary vars
as we open the file, read the content, close it, and search it. The value of
`with` is the value of its `do` parameter.

The inner var `content` is local to the `with`, and doesn't affect the content
defined outside of it.

### `with` and Pattern matching

In the above example, the head of the `with` expresion used `=` for basic
pattern matches. If any of those failed, a `MatchError` would be raised. So how
could we handle that in a more elegant way? The `<-` operator comes in. If
you use `<-` instead of `=` in a `with` expression, it performs a match, but
fails if it returns the value that couldn't be matched.

```elixir
with [a|_] <- [1,2,3], do: a  #=> 1
with [a,_] <- nil,     do: a  #=> nil
```

We can use this to let the `with` in the code further up to return `nil` if the
user cannot be found.

```elixir
result = with {:ok, file}   = File.open("/etc/passwd",
              content       = IO.read(file, :all),
              :ok           = File.close(file),
              [_, uid, gid] <- Regex.run(~r/xxx:*.?:(\d+):(\d+)/, content)
         do
           "Group: #{gid}, User: #{uid}"
         end

IO.puts inspect(result)  #=> nil
```

When we try to match the user `xxx`, `Regex.run` returns `nil`, causing the
match to fail, and the `nil` becomes the value of the `with`.

### A Minor Gotcha

`with` is treated by Elixir as if it were a call to a function or a macro, so
use parentheses or put the first set of args on the same line as the `with`
keyword. You can also use `do:` instead of `do`...`end`, and put the ``content
on the same line as the `do:`.

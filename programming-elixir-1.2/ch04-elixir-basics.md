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
Regex.replace ~{[aeiou]}, "caterpillar", "*"  #=> "c*t*rp*ll*r"
```

## System Types

These reflect resources in the underlying Erlang VM

### PIDs and Ports

a PID is a reference to a process (local or remote), and a port is a reference
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

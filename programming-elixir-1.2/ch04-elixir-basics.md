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

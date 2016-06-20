[&lt;&lt; Back to the README](README.md)

# Chapter 8. Maps, Keyword Lists, Sets and Structs

How do you choose an appropriate dictionary type for a particular need?

## How to Choose Between Maps and Keyword Lists

Questions to ask yourself (in this order):

1. Do I want to pattern-match against the contents?
   - **Yes**: use a map
2. Will I want more than one entry with the same key?
   - **Yes**: use the Keyword module
3. Do I need to guarantee the elements are ordered?
   - **Yes**: use the Keyword module
4. Otherwise
   - **Use a map**

## Keyword Lists

Typically used in the context of options passed to fns.

```elixir
defmodule Canvas do
  @defaults [ fg: "black", bg: "white", font: "Arial" ]

  def draw_text(text, options \\ []) do
    options = Keyword.merge(@defaults, options)
  end
end

Canvas.draw_text("hello", fg: "red", style: "italic", style: "bold")
```

For simple access, you can use the access operator `kwlist[key]`. You also have
all the fns of `Keyword` and `Enum` available.

## Maps

Maps are the go-to key/value data structure in Elixir. They have good
performance at all scales.

```elixir
map = %{ name: "Dave", likes: "Programming", where: "Dallas" }
Map.keys map
#=> [:likes, :name, :where]
Map.values map
#=> ["Programming", "Dave", "Dallas"]
map[:name]
#=> "Dave"
map1 = Map.drop map, [:where, :likes]
#=> %{name: "Dave"}
map2 = Map.put map, :also_likes, "Ruby"
#=>%{also_likes: "Ruby", likes: "Programming", name: "Dave", where: "Dallas"}
map.has_key? map1, :where
#=> false
{value, updated+map} = Map.pop map2, :also_likes
#=>{"Ruby", %{likes: Programming", name: "Dave", where: "Dallas"}}
Map.equal? map, updated_map
#=> true
```

## Pattern Matching and Updating Maps

Patterns tend to need to match on the existence of key(s):

```elixir
# bind the person
person = %{name: "Dave", height: 1.88}

# does a key exist? bind the value
%{name: a_name} = person

# do keys exist?
%{name: _, height: _} = person

# does a key exist with a particular value?
%{name: "Dave"} = person

# this fails due to no matching key for weight
%{name: _, weight: _} = person
```

Let's look at the destructuring that occurred in the first example.

```elixir
people = [
  %{name: "Grumpy", height: 1.24}
  %{name: "Dave", height: 1.88}
  %{name: "Dopey", height: 1.32}
  %{name: "Shaq", height: 2.16}
  %{name: "Sneezy", height: 1.28}
]

IO.inspect(for person = %{height: height} <- people, height > 1.5, do: person)
```

The above will output a list of maps of people that have `height > 1.5`.

We can also use this in `cond` expressions, fn head matching, etc.

```elixir
defmodule HotelRoom do
  def book(%{name: name, height: height}) when height > 1.9 do
    IO.puts "Extra long bed needed for #{name}
  end

  def book(%{name: name, height: height}) when height < 1.3 do
    IO.puts "Low shower controls needed for #{name}
  end

  def book(person) do
    IO.puts "Need a regular bed for #{person.name}"
  end
end

people |> Enum.each(&HotelRoom.book/1)
```

### Pattern Matching Can't Bind Keys

You can bind values, but not keys.

```elixir
# okay
%{2 => state} = {%1 => :ok, 2 => :error}

# not okay
%{item => :ok} = {%1 => :ok, 2 => :error}
```

### Pattern Matching Can Match Variable Keys

The pin operator `^` can be used to use the value already in a var on
the left-hand side of the match. This also works for the keys of a map.

```elixir
data = %{name: "Dave", state: "TS", likes: "Elixir"}
for key <- [:name, :likes] do
  %{^key => value} = data # the ^ means that the key is the value from the loop
  value
end
#=> ["Dave", "Elixir"]
```

## Updating a Map

A map is immutable, so a simple way to update a map is like this:

```elixir
new_map = %{old_map | key => value, ...}
```

This creates a new map that is a copy of the old, but the values associated
with the keys on the right pipe are updated:

```elixir
m = %{a: 1, b: 2, c: 3}

m1 = %{m | b: "two", c: "three"}
#=> %{a: 1, b: "two", c: "three"}
```

This only updates a map. To add a new key, you need to use `Map.put_new/3`.

## Structs

When Elixir sees `%{...}` it knows it is looking at a map, but nothing else. In
particulare, it doesn't know your intentions, key restrictions, etc.

This is fine for anonymous maps, but what about a typed map? Y'know, a map that
has a fixed set of fields and default values for said fields, and that you can
pattern-match by type as well as content?

Enter the `struct`. A struct is a module that wraps a limited form of map. It's
limited because the keys must be atoms and because these maps don't have `Dict`
capabilities.

The name of the module becomes the name of the map type. Inside the module, you
use `defstruct` to define the map's characteristics.

```elixir
defmodule Subscriber do
  defstruct name: "", paid: false, over_18: true
end

s1 = %Subscriber{}
#=> %Subscriber{name: "", over_18: true, paid: false}
s2 = %Subscriber{name: "Dave"}
s3 = %Subscriber{name: "Mary", paid: true}
```

The syntax for creating a struct is the same as for creating a map. You can
access the fields in a struct using dot notation or pattern matching:

```elixir
s3.name
#=> "Mary"
%Subscriber{name: a_name} = s3
#=> %Subscriber{name: "Mary", over_18: true, paid: true}
a_name
#=> "Mary"

#updating
s4 = %Subscriber{s3 | name: "Marie"}
#=> %Subscriber{name: "Marie", over_18: true, paid: true}
```

Structs are wrapped in a module because it is likely you want to add
struct-specific behavior.

```elixir
defmodule Attendee do
  defstruct name: "", paid: false, over_18: true

  def may_attend_after_party(attendee = %Attendee{}) do
    attendee.paid && attendee.over_18
  end

  def print_vip_badge(%Attendee{name: name}) when name != "" do
    IO.puts "Very cheap badge for #{name}"
  end

  def print_vip_badge(%Attendee{}) do
    raise "missing name for badge"
  end
end
```

Notice how we could call the fn in the `Attendee` module to manipulate the
associated struct.

Structs also play a large role in polymorphism.

## Nested Dictionary Structures

Various dictionary types let us associate keys with values, but the values can
also be dictionaries. In a bug reporting system, we could have the following:

```elixir
defmodule Customer do
  defstruct name: "", company: ""
end

defmodule BugReport do
  defstruct owner: %Customer{}, details: "", severity: 1
end

report = %BugReport{owner: %Customer{name: "Dave", company: "Pragmatic"},
                    details: "broken", severity: 1}
```

The `owner` attribute of the report is a Customer struct.

You can access the fields using dot notation, as well

```elixir
report.owner.company
```

We can even update the company name.

```elixir
report = %BugReport{ report | owner: %Customer{report.owner | company: "PragProg"}}
```

As you can see, this can get ugly fast. It can be verbose, hard to read, and
error prone. You can use `put_in` to set a value in a nested structure.

```elixir
put_in(report.owner.company, "PragProg")
```

This isn't magic, it's simply a macro that generates the code we would have had
to write.

You can also use `update_in` to apply a fn to a value in a struct.

```elixir
update_in(report.owner.name, &("Mr. " <> &1))
```

The other two nested functions are `get_in` and `get_and_update_in`. Both of
these fn support **nested access**.

### Nested Accessors and Nonstructs

If you are using the nested accessor fns with maps or keyword lists, you can
supply the keys as atoms:

```elixir
report = %{owner: %{name: "Dave", company: "Pragmatic"}, severity: 1}

put_in(report[:owner][:company], "PragProg")

update_in(report[:owner][:name], &("Mr. " <> &1))
```

### Dynamic (Runtime) Nested Accessors

The nested accessors thus far have been macros, and operate at compile time.
They have certain limitations.

- The number of keys you pass is static.
- You cannot pass the set of keys as params between fn.

To overcome this, `get_in`, `put_in`, `update_in`, and `get_and_update_in` can
all take a list of keys as a separate param. This changes them from macros to
fn calls, so they become dynamic.

| function          | macro         | function            |
| ----------------- | ------------- | ------------------- |
| get_in            | *no*          | (dict, keys)        |
| put_in            | (path, valu   | (dict, keys, value) |
| update_in         | (path, fn)    | (dict, keys, fn)    |
| get_and_update_in | (path, fn)    | (dict, keys, fn)    |

Simple example:

```elixir
nested = %{
            buttercup: %{
              actor: %{
                first: "Robin",
                last: "Wright"
              },
              role: "princess"
            },
            westley: %{
              actor: %{
                first: "Carey",
                last: "Ewes"
              },
              role: "farm boy"
            }
}

IO.inspect get_in(nested, [:buttercup])
#=> %{actor: %{first: "Robin", last: "Wright"}, role: "princess"}

IO.inspect get_in(nested, [:buttercup, :actor])
#=> %{first: "Robin", last: "Wright"}

IO.inspect get_in(nested, [:buttercup, :actor, :first])
#=> "Robin"

IO.inspect put_in(nested, [:westley, :actor, :last], "Elwes")
#=> %{buttercup: %{actor: %{first: "Robin", last: "Wright"}, role: "princess"},
#=> westley: %{actor: %{first: "Carey", last: "Elwes"}, role: "farm boy"}}
```

You can also do something nifty with `get_in` and `get_and_update_in`. If you
pass a fn as a key, that fn is invoked to return the corresponding values.

```elixir
authors = [
  %{name: "Jose", language: "Elixir"},
  %{name: "Matz", language: "Ruby"},
  %{name: "Larry", language: "Perl"}
]

languages_with_an_r = fn (:get, collection, next_fn) ->
  for row <- collection do
    if String.contains?(row.language, "r") do
      next_fn.(row)
    end
  end
end

IO.inspect get_in(authors, [languages_with_an_r, :name])
#=> ["Jose", nil, "Larry"]
```

## Sets

The only implementation is the `MapSet`

```elixir
set1 = Enum.into 1..5, MapSet.new
#=> MapSet<[1, 2, 3, 4, 5]>
MapSet.member? set1, 3
#=> true
set2 = Enum.into 3..8, MapSet.new
#=> MapSet<[3, 4, 5, 6, 7, 8]>
MapSet.union set1, set2
#=> MapSet<[7, 6, 4, 1, 8, 2, 3, 5]>
MapSet.difference set1, set2
#=> MapSet<[1, 2]>
MapSet.difference set2, set1
#=> MapSet<[6, 7, 8]>
MapSet.intersection set1, set2
#=> MapSet<[3, 4, 5]>
```

## With Great Power Comes Great Temptation

Don't use these structs like you would expect to be able to use classes.

Elixir is a functional language and mixing paradigms is not good.


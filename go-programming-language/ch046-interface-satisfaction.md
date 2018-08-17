[🔙 Interface Types][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Parsing Flags with flag Value 🔜][upcoming-chapter]

# Chapter 46. Interface Satisfaction

A type _satisfies_ an interface if it posses all the methods an interface requires. As a shorthand,
Go programmers often say that a concrete type "is a" particular interface type, meaning that it
satisfies the interface. A `*bytes.Buffer` is an `io.Writer`; an `*os.File` is an `io.ReadWriter`.

Th assignability rule for interfaces is very simple: an expression may be assigned to an interface
only if its type satisfies the interface. This rule applies even when the right-hand side is, itself,
an interface.

There are times where you need a var to satisfy an interface, too. 

```go
type IntSet struct { /* ... */ }
func (*IntSet) String() string

var _ = IntSet{}.String() // compile error: String requires *IntSet receiver
                          // compile error: cannot call pointer method on IntSet literal
                          // compile error: cannot take the address of IntSet literal
var s IntSet
var _ = s.String() // OK: s is a variable and &s has a string methodk
```

However, single only `*IntSet` has a `String()` method, only `*IntSet` satisfies the `fmt.Stringer`
interface.

```go
var _ fmt.Stringer = &s // OK
var _ fmt.Stringer = s  // compile error: cannot use s (type IntSet) as type fmt.Stringer in assignment:
                        //	IntSet does not implement fmt.Stringer (String method has pointer receiver)
```

Loke an envelope that wraps and conceals the letter it holds, an interface wraps and conceals the
concrete type and value that it holds. Only the methods revealed by the interface type may be called,
even if the concrete type has other methods.

## Empty Interfaces

An interface often tells us about the values it contains, but what does the type `interface{}`, which
has no methods at all, tell us about the concrete types that satisfy it?

Nothing. And this is big, and good. The _empty interface_ is indispensable, because it places no
demands on the types that satisfy it, we can assign _any_ value to the empty interface.

You might be surprised to learn that we've been using it _all along!_ `fmt.Println`, `errorf`, etc,
all use it to accept any type of argument.

Since interface satisfaction depends only on the methods of the two types involved, there is no need
to declare the relationship and the interfaces it satisfies. You may want to document when this
relationship is intended, though.

```go
// *bytes.Buffer must satisfy io.Writer
var _ io.Writer = new(bytes.Buffer)
```

Pointer types are by no means the only types that satisfy interfaces, and even interfaces with
mutator methods may be satisfied by one of Go's other reference types. We've seen slice types with
methods (`geometry.Path`), and map types with methods (`url.Values`), and later we'll see a fn type
with methods (`http.HandlerFunc`). Even basic types may satisfy interfaces, as `time.Duration`
satisfies `fmt.Stringer`.

A concrete type may satisfy many unrelated interfaces. Consider a program that handles digitized
cultural artifacts like music, films, books, etc. You could have the following concrete types:

```go
Album
Book
Movie
Magazine
Podcast
TVEpisode
Track
```

We can express each abstraction of interest as an interface. Some properties are common to them all:

```go
type Artifact interface {
  Title() string
  Creators() []string
  Created() time.Time
}
```

Other properties are restricted to certain types of artifacts, like books and magazines, or movies
and tv:

```go
type Text interface {
    Pages() int
    Words() int
    PageSize() int
}

type Audio interface {
    Stream() (io.ReadCloser, error)
    RunningTime() time.Duration
    Format() string // e.g., "MP3", "WAV"
}

type Video interface {
    Stream() (io.ReadCloser, error)
    RunningTime() time.Duration
    Format() string // e.g., "MP4", "WMV"
    Resolution() (x, y int)
}
```

These interfaces are but one useful way to group related concrete types together and express the
faccets they share in common. We may discover other groupings later. Like, if we need find we need
to handle `Audio` and `Video` items in the same way, we could create a `Streamer` interface for it:

```go
type Streamer interface {
    Stream() (io.ReadCloser, error)
    RunningTime() time.Duration
    Format() string
}
```

Each grouping can be expressed as an interface type. Unlike class-based languages, where the set of
interfaces satisfied by a class are explicit, in Go we can define new abstractions or groupings of
interest when we need them, without modifying the declaration of the concrete type. Super helpful
when the concrete type is in a 3rd-party library!



[🔙 Interface Types][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Parsing Flags with flag Value 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch045-interface-types.md
[upcoming-chapter]: ch047-parsing-flags-with-flag-value.md

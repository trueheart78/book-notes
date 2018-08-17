[🔙 Encapsulation][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Interface Types 🔜][upcoming-chapter]

# Chapter 44. Interfaces as Contracts

Everything up until now, type-wise, has been _concrete_: specifying the exact representation of its
values and exposes the intrinsic ops of that representation (arithmetic, indexing, etc). Concrete
types let you know exactly what it _is_ and what you can _do_ with it.

There is another kind of type in Go called an _interface type_, aka an _abstract type_. It doesn't
expose the representation or internal structure of its values, or the set of basic ops they support;
ot reveals only some of their methods. When you have a value of an interface type, you know nothing
about what it _is_; only what it can _do_, or more precisely, what behaviors are provided by its
methods.


## `io.Writer` Interface

In the `fmt` pkg, `fmt.Printf` and `fmt.Sprintf` are actually just wrappers around `fmt.FPrintf`.
The `F` prefix of `fmt.FPrintf` stands for _file_ and indicates that the formatted output should be
written to a file. In `fmt.Printf`, we pass through an `*os.File`. In `fmt.Sprintf`, though, we
use `&buf`, which is a pointer to a memory buffer where bytes can be written.

These are both using the `io.Writer` interface [(pkg/io#Writer)](https://golang.org/pkg/io/#Writer).
This is one of the most notable interfaces, as its simple but very effective.

```go
type Writer interface {
  Write(p []byte) (n int, err error)
}
```

Since it's an interface, as long as we pass something that meets the requirements to `fmt.FPrintf`,
it will be allowed safe passage. It literally just needs to meet the behavior and signature, then we
can _substitute_ it. This is a core feature of OOP.

Let's create a new type and see what we can do. Remember, the type of the object doesn't matter as
much as it does the interface.

```go
type ByteCounter int

func (c *ByteCounter) write(p []byte) (int, error) {
  *c += ByteCounter(len(p)) // convert the int to ByteCounter
  return len(p), nil
}
```

Since this now satisfies the `io.Writer` contract, let's pass it to `fmt.FPrintf`

```go
var c ByteCounter
c.Write([]byte("hello"))
fmt.Println(c) // "5", = len("hello")

c = 0
var name = "Dolly"
fmt.FPrintf(&c, "hello, %s", name)
fmt.Println(c) // "12", = len("hello, Dolly")
```

## `fmt.Stringer` Interface

Think of the Ruby `.to_s` method, and that's what the goal of this interface satisfies 
[(pkg/fmt#Stringer)](https://golang.org/pkg/fmt/#Stringer). Just declare a `String` method and it
will satisfy the contract that is the `fmt.Stringer` interface.

We'll look more into this in the [Type Assertions chapter](ch053-type-assertions.md) section of
interfaces.

[🔙 Encapsulation][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Interface Types 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch043-encapsulation.md
[upcoming-chapter]: ch045-interface-types.md

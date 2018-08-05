[🔙 Declarations][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Assignments 🔜][upcoming-chapter]

# Chapter 11. Variables

## 2.3.2 Pointers

A _variable_ is a piece of storage containing a valie. Vars created by declarations are identified
by a name, such as `x`, but many variables are identified only by expressions like `x[i]` or `x.f`.
All of these read the value of a var, except when they appear on the _left-hand_ side of an 
assignment, in which case, a new value is assigned to it.

A _pointer_ value is the (_memory_) _address_ of a variable. A pointer is the location at which a 
value is stored. Not every value has an address, but every var does. With a pointer, we can read or 
update the value of a variable _indirectly_, without using or even knowing its name.

If a variable is declared `var x int`, the expression `&x` ("the address of `x`") yields a pointer
to an integer var, that is, a value of type `*int`, which is pronounced "pointer to `int`." If this
value is called `p`, we say "`p` points to `x`", or "`p` contains the address of `x`." The var to
which `p` points is written `*p`. The expression `*p` yields the value of that var, an `int`, but
since `*p` denotes a var, it may also appear on the _left-hand_ side of an assignment, in which case
the assignment updates the var.

```go
x := 1
p := &x         // p, of type *int, points to x
fmt.Println(*p) // "1"
*p = 2          // same as x = 2
fmt.Println(x)  // "2"
```

Each component of a var of aggregate type (a field of a struct or an element of an array) is also a
var and thus have addresses, as well.

Vars are sometimes described as _addressable_ values. Expressions that denote vars are the only
expressions to which the _address-of_ operator `&` may be applied.

The zero value for a pointer of any type is `nil`. The test `p != nil` is true if `p` points to a
var. Pointers are comparable; two pointers are equal if and only if they point to the same var or
are both `nil`.

```go
var x, y int
fmt.Println(&x == &x, &x == &y, &x == nil) // "true false false"
```

It is perfectly safe for a fn to return the address of a local var. For instance, the local var `v`
created by this particular call to `f` will remain in existence even after the call has returned,
and the pointer `p` will still refer to it.

```go
var p = f()

func f() *int {
  v := 1
  return &v
}
```

Each call of `f` returns a distinct address for each newly created local var.

```go
fmt.Println(f() == f()) // "false"
```

Because a pointer contains the address of a var, passing a pointer arg to a fn makes it possible for
the fn to update the var that was indirectly passed. FOr example, this fn increments the var that
its arg points to and returns the new value of the var so it may be used in an expression:

```go
func incr(p *int) int {
  *p++ // increments what p points to; does not change p
  return *p
}

v := 1
incr(&v)              // side effect: v is now 2
fmt.Println(incr(&v)) // "3" and v is now 3
```

Each time we take the address of a var or copy a pointer, we create new _aliases_ or ways to
identify the same var. For example, `*p` is an _alias_ for `v`. Pointer aliasing is useful because
it allows us to access a var without using its name, but this is a double-edged sword: to find all
the statements that access a var, we have to know all its aliases. It's not just pointers that
create aliases; aliasing also occurs when we copy values of other reference types (like slices,
maps, channels, structs, arrays, and interfaces).

Pointers are key to the `flag` package, which uses a program's commandline-arguments to set the
value of certain vars distributed throughout the program. To illustrate, this var on the earlier
`echo` command takes two optional flags: `-n` causes `echo` to omit the trailing newline that would
normally be printed, and `-s sep` causes it to separate the output args by the contents of the
string passed in instead of the default single space.

This example is `gopl.io/ch2/echo4`:

```go
// Echo4 prints its command-line arguments.
package main

import (
    "flag"
    "fmt"
    "strings"
)

var n = flag.Bool("n", false, "omit trailing newline")
var sep = flag.String("s", " ", "separator")

func main() {
    flag.Parse()
    fmt.Print(strings.Join(flag.Args(), *sep))
    if !*n {
        fmt.Println()
    }
}
```

The fn `flag.Bool` creates a new flag var of type `bool`, and it takes three args: name ("`n`"),
the default value (`false`), and a message that will be printed if the user provides an invalid
argument, an invalid flag, or `-h` or `-help`. Similarly, `flag.String` takes a name, a default val,
and a message, and creates a `string` var. The vars `sep` and `n` are pointers to the flag vars,
which must be accessed indirectly as `*sep` and `*n`.

When the program is run, it must call `flag.Parse` before the flags are used, to update the flag
vars from their default values. The non-flage args are available from `flag.Args()` as a slice of
strings. If `flag.Parse` encounters an error, it prints a usage message and calls `os.Exit(2)` to
terminate the program.

Here's some testing for `echo`:

```
$ go build gopl.io/ch2/echo4
$ ./echo4 a bc def
a bc def
$ ./echo4 -s / a bc def
a/bc/def
$ ./echo4 -n a bc def
a bc def$
$ ./echo4 -help
Usage of ./echo4:
  -n    omit trailing newline
  -s string
        separator (default " ")
```

[🔙 Declarations][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Assignments 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch010-declarations.md
[upcoming-chapter]: ch012-assignments.md

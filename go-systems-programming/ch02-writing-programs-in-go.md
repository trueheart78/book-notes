[🔙 Getting Started with Go and Unix Systems Programming][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Advanced Go Features 🔜][upcoming-chapter]

# Chapter 2. Writing Programs in Go

## Overview

* Running: `go run example.go`
* Building: `go build example.go` will create an `example` binary in the current directory.
* Installing: `go install example.go` will create an `example` binary in `$GOPATH/bin`.
* Formatting: `gofmt example.go` will format your file properly, and let you know if you have any
linter-based errors.

## Using Commandline Arguments

To read arguments passed in, you'll need to `os` package. `os.Args` will provide you with all args
passed in.

```go
package main 
 
import (
   "fmt" 
   "os" 
)
 
func main() { 
   arguments := os.Args 
   for i := 0; i < len(arguments); i++ { 
         fmt.Println(arguments[i]) 
   } 
}
```

## User Input and Output

The [Go Format Package][pkg/fmt] documentation can be very helpful in a pinch.

### Getting User Input

The basics of getting simple input from the user. We could use the [`bufio` package][pkg/bufio],
but that's overkill for our basic needs.


```go
package main

import (
  "fmt"
  "os"
  "strings"
)

func main() {
  arguments := os.Args
  minusI := false
  for i := 0; i < len(arguments); i++ {
    if strings.Compare(arguments[i], "-i") == 0 {
      minusI = true
      break
    }
  }

  if minusI {
    fmt.Println("Got the -i parameter!")
    fmt.Print("y/n: ")
    var answer string
    fmt.Scanln(&answer)
    fmt.Println("You entered:", answer)
  } else {
    fmt.Println("The -i parameter is not set")
  }
}
```

Sample run:

```
$ go run parameter.go
The -i parameter is not set
$ go run parameter.go -i
Got the -i parameter!
y/n: y
You entered: y
```

The presented code is not very clever, but it works. It checks each argument and if the `-i` is
detected, it will let the user enter input.  It uses `strings.Compare()` to check if the flag
was entered.

:warning: Notice that the call to `fmt.Scanln()` uses a pointer value to the `answer` variable, 
since we need to use a pointer to save the user input into the `answer` variable. This tends to
be the way that functions that read data from the user work.

### Printing Output

Simplest way to print something in Go:

* `fmt.Println()` adds a newline at the end of the output.
* `fmt.Print()` does not add a newline at the end of the output.
* `fmt.Printf()` requires a **verb** from the [supported verbs][pkg/fmt]. Does not add a newline
to the end of the output.

## Go Functions

💡 _As a rule of thumb, you should try to write functions that are less than 20-30 lines of Go
code. This allows better optimization since you can more easily find out where a bottleneck may
be._

### Naming Return Values of a Function

Unlike C, Go allows you to name the return values of a function. So when a function has a `return`
statement without any arguments, the function automatically returns the current value of each
named return value.

💡 _Naming return values is a very handy Go feature that can save you from various bugs, so use
it._

### Anonymous Functions

You can define a function inline, without the need for a name, and are good for implementing 
things that require a small amount of code. In Go, a function can return an anonymous function or
take one as an argument. They can also be attached to variables.

### Illustrating Go Functions

Som self-informative code to show off the different ways that functions can be defined, and
called.

```go
package main

import (
  "fmt"
)

// no named return values
func unnamedMinMax(x, y int) (int, int) {
  if x > y {
    min := y
    max := x
    return min, max
  } else {
    min := x
    max := y
    return min, max
  }
}

// named return values
func minMax(x, y int) (min, max int) {
  if x > y {
    min = y
    max = x
  } else {
    min = x
    max = y
  }
  return min, max
}

// named return values with naked return values
func namedMinMax(x, y int) (min, max int) {
  if x > y {
    min = y
    max = x
  } else {
    min = x
    max = y
  }
  return
}

// sort without using an extra variable
func sort(x, y int) (int, int) {
  if x > y {
    return x, y
  } else {
    return y, x
  }
}

func main() {
  y := 4
  // anonymous function usage
  square := func(s int) int {
    return s * s
  }
  fmt.Println("The square of", y, "is", square(y))

  square = func(s int) int {
    return s + s
  }
  fmt.Println("The square of", y, "is", square(y))

  // named function usage
  fmt.Println(minMax(15, 6))
  fmt.Println(namedMinMax(15, 6))
  min, max := namedMinMax(12, -1)
  fmt.Println(min, max)
}
```

Running it will display the following:

```
$ go run functions.go
The square of 4 is 16
The square of 4 is 8
6 15
6 15
-1 12
```

### The `defer` Keyword

`defer` defers the execution of a function until the surrounding function returns, and is widely
used in file I/O. This is because it saves you from having to do things like remembering to close
an open file.

```go
package main

import (
  "fmt"
)

// LIFO - will print 2 1 0
func a1() {
  for i := 0; i < 3; i++ {
    defer fmt.Print(i, " ")
  }
}

// LIFO - the function body is run after the for loop completes
//        and results in the printing of 3 3 3
func a2() {
  for i := 0; i < 3; i++ {
    defer func() { fmt.Print(i, " ") }()
  }
}

// LIFO - since we're passing in the value, it does not use the
//        value of i after the loop completes. Will print 2 1 0
func a3() {
  for i := 0; i < 3; i++ {
    defer func(n int) { fmt.Print(n, " ") }(i)
  }
}

func main() {
  a1()
  fmt.Println()
  a2()
  fmt.Println()
  a3()
  fmt.Println()
}
```

You'll get the following output when running the above code:

```
$ go run defer.go
2 1 0
3 3 3
2 1 0
```

Now... why? Let's dissect that.

The first line of output verifies that deferred functions are executed in a **Last In First Out
(LIFO)** order after the return of the surrounding function.

See the comments for details on each usage and the _why_ of the output.

### Using Pointer Variables in Functions

**Pointers** are memory addresses that offer improved speed in exchange for difficult-to-debug
code and nasty bugs. C programmers know about this. 

Let's see how Go uses them:

```go
package main

import (
  "fmt"
)

// requires no return value since we're changing the pointer reference
func withPointer(x *int) {
  *x = *x * *x
}

type complex struct {
  x, y int
}

// requires a return value
func newComplex(x, y int) *complex {
  return &complex{x, y}
}

func main() {
  x := -2
  // pass by pointer reference requires a leading '&'
  withPointer(&x)
  // will print the changed value: 4
  fmt.Println(x)

  w := newComplex(4, -5)
  // will print the actual data: {4 -5}
  fmt.Println(*w)
  // will print the reference to the data: &{4 -5}
  fmt.Println(w)
}
```

As the `withPointer()` fn uses a pointer var, you don't need to return any values because any
changes to the var you pass to the fn are automatically stored in the passed var. To pass as
a pointer (by reference, by pointer reference), make sure to put a `&` before the var. The
`complex` struct has two members, `x` and `y`, both `int` vars.

The `newComplex()` fn returns a pointer to a `complex` struct, previously defined in the file,
and which needs to be stored in a var. In order to print the contents of a complex var returned
by the `newComplex()` fn, you need to put a `*` in front of it.

## Go Data Structures

Arrays are strict, Slices are dynamic arrays, Maps are like hashes/dictionaries.

### Maps

Think hashes or dictionaries.

To validate if a key exists, check the second return element when referencing the key:

```go
_, ok := aMap["Tuesday"] 
if ok { 
   fmt.Printf("The Tuesday key exists!\n") 
} else { 
   fmt.Printf("The Tuesday key does not exist!\n") 
}
```

### Converting an Array to a Map

```go
package main

import (
  "fmt"
  "strconv"
)

func main() {
  anArray := [4]int{1, -2, 14, 0}
  aMap := make(map[string]int)

  length := len(anArray)

  // visit all elements of the array and add them to the map
  for i := 0; i < length; i++ {
    fmt.Printf("%s ", strconv.Itoa(i))
    // key is the int converted to a string, value is the int itself
    aMap[strconv.Itoa(i)] = anArray[i]
  }

  // print the mapped values using a range (think foreach)
  for key, value := range aMap {
    fmt.Printf("%s: %d\n", key, value)
  }
}
```

### Structures

Structs allow us to hold multiple values in the same place. When you need to group various types
of data and create a new handy type, the struct is your friend.

```go
package main

import (
  "fmt"
  "reflect"
)

func main() {

  // message has 3 fields: X, Y, and Label
  type message struct {
    X     int
    Y     int
    Label string
  }

  // initialize with passed values
  p1 := message{23, 12, "A Message"}

  // initialize with zero values
  p2 := message{}

  // assign a new value
  p2.Label = "Message 2"

  s1 := reflect.ValueOf(&p1).Elem()
  s2 := reflect.ValueOf(&p2).Elem()

  // prints: S2= {0 0 Message 2}
  fmt.Println("S2=", s2)

  typeOfT := s1.Type()
  // prints: P1= {23 12 A Message}
  fmt.Println("P1=", p1)
  // prints: P2= {0 0 Message 2}
  fmt.Println("P2=", p2)

  for i := 0; i < s1.NumField(); i++ {
    f := s1.Field(i)

    // print the value using _any_ type
    fmt.Printf("%d: %s ", i, typeOfT.Field(i).Name)
    fmt.Printf("%s = %v\n", f.Type(), f.Interface())
  }
}
```

Output:

```
S2= {0 0 Message 2}
P1= {23 12 A Message}
P2= {0 0 Message 2}
0: X int = 23
1: Y int = 12
2: Label string = A Message
```

If the name of a field of a struct definition begins with a lowercase letter (x instead of X),
the previous program will fail with the following error message:

```
panic: reflect.Value.Interface: cannot return value obtained from unexported field or method
```

This can happen when lowercase fiels don't get experted, so they can't be used by the
`reflect.Value.Interface()` method. 

## Interfaces

Interfaces are an advanced Go feature, which means you may want to avoid them until you are quite
comfortable with Go. Since we're talking about writing bigger Go programs, we'll cover interfaces,
as they can be very practical.

Let's first talk about methods, though. These are functions with a special receiver argument. You
declare methods as ordinary functions but with an additional param that appears just before the fn
name. This connects the fn to the _type_ of that extra param, aka the _receiver_ of the method.

Interfaces are abstract types that define a set of fn that need to be implemented so that a type
can be considered an instance of the interface. Like duck typing. It's an instance of an
interface if it responds to the correct methods. It basically _satisfies_ the interface.

So an interface is two things: a set of methods, and a type, and it is used for defining the
behavior of a type.

Read the comments and see the output for the _why_ and the _how_:

```go
package main

import (
  "fmt"
)

// declare an interface that has two methods required
type coordinates interface {
  xaxis() int
  yaxis() int
}

// declare a new type called point2D
type point2D struct {
  X int
  Y int
}

// create the xaxis() method on the point2D type
func (s point2D) xaxis() int {
  return s.X
}

// create the yaxis() method on the point2D type
func (s point2D) yaxis() int {
  return s.Y
}

// call the xaxis() and yaxis() method on the passed in coordinates interface
// notice this is not a coordinate (singular) or point2D type, it is the interface
// defined further above
func findCoordinates(a coordinates) {
  fmt.Println("X:", a.xaxis(), "Y:", a.yaxis())
}

// declare a new type called coordinate
type coordinate int

// create the xaxis() method on the coordinate type
// and return the integer value of the related type
func (s coordinate) xaxis() int {
  return int(s)
}

// create the yaxis() method on the coordinate type
// and return 0
func (s coordinate) yaxis() int {
  return 0
}

func main() {
  // new point2D instance
  x := point2D{X: -1, Y: 12}
  fmt.Println(x)

  // send in the point2D var - prints X: -1 Y: 12
  findCoordinates(x)

  y := coordinate(10)
  // send in the point2D var - prints X: 10 Y: 0
  findCoordinates(y)
}
```

Example output:

```
{-1 12}
X: -1 Y: 12
X: 10 Y: 0
```

Go interfaces are not necessary all the time, and less so when developing system software, but
they are a handy Go feature that can make the development of a system app more readable and
simpler, so don't feel like you need to avoid them.

## Creating Random Numbers

Go uses the [`math/rand` package][pkg/math/rand] for generating random numbers. **It needs a seed
to start producing random numbers**, and the seed is used for initializing the entire process, and
is _extremely important_, because if you always start with the same seed, you'll always get the
same sequence of "random" numbers.


```go
package main

import (
  "fmt"
  "math/rand"
  "os"
  "strconv"
  "time"
)

// generate a random integer between the min and max
func random(min, max int) int {
  return rand.Intn(max-min) + min
}

func main() {
  MIN := 0
  MAX := 0
  TOTAL := 0
  // we need more than 3 arguments, the 0 being the binary
  if len(os.Args) > 3 {
    MIN, _ = strconv.Atoi(os.Args[1])
    MAX, _ = strconv.Atoi(os.Args[2])
    TOTAL, _ = strconv.Atoi(os.Args[3])
  } else {
    // prints "Usage: [binary] MIN MAX TOTAL
    fmt.Println("Usage:", os.Args[0], "MIN MAX TOTAL")
    os.Exit(-1)
  }

  // use the epoch as the seed
  rand.Seed(time.Now().Unix())

  // createe TOTAL random numbers and print them out
  for i := 0; i < TOTAL; i++ {
    myrand := random(MIN, MAX)
    fmt.Print(myrand, " ")
  }
  fmt.Println()
}
```

Let's request 5 random numbers between 1 and 10:

```
$ go run random.go 1 10 5
5 6 4 6 8
```

Now, if you want more secure random number generation, check out the
[`crypto/rand` package][pkg/crypto/rand].

[🔙 Getting Started with Go and Unix Systems Programming][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Advanced Go Features 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch01-getting-started-with-go-and-unix-systems-programming.md
[upcoming-chapter]: ch03-advanced-go-features.md
[pkg/fmt]: https://golang.org/pkg/fmt/
[pkg/math/rand]: https://golang.org/pkg/math/rand/
[pkg/crypto/rand]: https://golang.org/pkg/crypto/rand/

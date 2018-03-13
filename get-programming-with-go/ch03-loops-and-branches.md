[🔙 A Glorified Calculator][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Variable Scope 🔜][upcoming-chapter]

# Chapter 3. Loops and Branches

## True and False, That's it.

In Go, the only values that are `true` and `false` (unlike `nil` in Ruby), are `true`
and `false`.

```go
package main

import (
    "fmt"
    "strings"
)

func main() {
     fmt.Println("You find yourself in a dimly lit cavern.")

     var command = "walk outside"
     var exit = strings.Contains(command, "outside")

     fmt.Println("You leave the cave:", exit)
}

// You leave the cave: true
```

## Comparisons

```go
mt.Println("There is a sign near the entrance that reads 'No Minors'.")

var age = 40
var minor = age < 18

fmt.Printf("At age %v, am I a minor? %v\n", age, minor)

// There is a sign near the entrance that reads 'No Minors'.
// At age 40, am I a minor? false
```

💡 Note: There are no `===` operators in Go. You will need to convert types to handle
these instances. You'll see that in [Chapter 10. Converting Between Types][chapter-10].

## Branching If

```go
package main

import "fmt"

func main() {
    var command = "go east"

    if command == "go east" {
      fmt.Println("You head further up the mountain.")
    } else if command == "go inside" {
      fmt.Println("You enter the cave where you live out the rest of your life.")
    } else {
      fmt.Println("Didn't quite get that.")
    }
}

// You head further up the mountain.
```

## Logical Operators

In Go, `||` means _or_ and `&&` means _and_. Pretty straightforward.

Leap year detection is a thing, so let's do that.

* Any year that is even divisible by 4 bit not even divisibly by 100.
* Or any year that is evenly divisible by 400

```go
fmt.Println("The year is 2100, should you leap?")

var year = 2100
var leap = year%400 == 0 || (year%4 == 0 && year%100 != 0)

if leap {
    fmt.Println("Look before you leap!")
} else {
    fmt.Println("Keep your feet on the ground.")
}

// The year is 2100, should you leap?
// Keep your feet on the ground.
```

💡 Note: You can still use the `!` to invert boolean values.

## Branching with Switch


```go
fmt.Println("There is a cavern entrance here and a path to the east.")
var command = "go inside"

switch command {
case "go east":
    fmt.Println("You head further up the mountain.")
case "enter cave", "go inside":
    fmt.Println("You find yourself in a dimly lit cavern.")
case "read sign":
    fmt.Println("The sign reads 'No Minors'.")
default:
    fmt.Println("Didn't quite get that.")
}

// There is a cavern entrance here and a path to the east.
// You find yourself in a dimly lit cavern.
```

You can also use a `switch` statement like an `if...else`, with the addition of the
`fallthrough` to execute the body of the next `case`.


```go
var room = "lake"

switch {
case room == "cave":
    fmt.Println("You find yourself in a dimly lit cavern.")
case room == "lake":
    fmt.Println("The ice seems solid enough.")
    fallthrough
case room == "underwater":
    fmt.Println("The water is freezing cold.")
}

// The ice seems solid enough.
// The water is freezing cold.
```

## Repetition with Loops

Use the `for`, Luke!


```go
ipackage main

import (
    "fmt"
    "time"
)

func main() {
    var count = 10

    for count > 0 {
        fmt.Println(count)
        time.Sleep(time.Second)
        count--
    }
    fmt.Println("Liftoff!")
}
```

In the previous listing, a `count` is displayed for each iteration of a loop.
Before each iteration, the expression `count > 0` is evaluated, producing a
Boolean value. If the value is `false`, the loop terminates, otherwise it runs
the body of the loop (the code between `{` and `}`).

An inifinte loop doesn't specify a `for` condition, but you can still use
`break` to kick out at any time.

```go
var degrees = 0

for {
    fmt.Println(degrees)

    degrees++
    if degrees >= 360 {
        degrees = 0
        if rand.Intn(2) == 0 {
            break
        }
    }
}
```

[🔙 A Glorified Calculator][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Variable Scope 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch02-a-glorified-calculator.md
[upcoming-chapter]: ch04-variable-scope.md
[chapter-10]: ch10-converting-between-types.md

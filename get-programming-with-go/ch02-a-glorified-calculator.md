[🔙 Get Ready, Get Set, Go][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Loops and Branches 🔜][upcoming-chapter]

# Chapter 2. A Glorified Calculator

Solving mathematical problems are the thing to do in this chapter.

## Performing Calculations

Wanna be younger and weigh a little less? Mars can hook you up! A year on Mars is
687 Earth days, and lower gravity means everything weighs 38% of what it does on
Earth.

To calculate how young and light you would be on Mars, you can use the following
program.


```go
// my weight loss program
package main

import "fmt"

func main() {
  fmt.Print("My weight on the surface of Mars is ")
  fmt.Print(154.0 * 0.3783)
  fmt.Print(" lbs and I would be ")
  fmt.Print(40 * 365 / 687)
  fmt.Print(" years old.")
}
```

If the above is too... blocky, `Println` can receive multiple arguments.

```go
fmt.Println("My weight on the surface of Mars is", 154.0*0.3783, "lbs, and I would be", 40*365.2425/687, "years old.")
```

`My weight on the surface of Mars is 58.2582 lbs, and I would be 21.265938864628822 years old.`

### 💡 Tip

After modifying your code, click the `Format` button in the Go Playground. It will
automatically reformat the indentation and spacing of your code without breaking it.

## Formatted Print

The `Print` and `Println` functions have a sibling that gives more control over output.
By using `Printf`, you can insert values anywhere in the text.

```go
fmt.Printf("My weight on the surface of Mars is %v lbs", 154.0*0.3783)
fmt.Printf(" and I would be %v years old.\n", 40*365/687)
```

`Println` automatically moves to the next line, but `Printf` and `Print` do not.

`Printf` can handle multiple format verbs with arguments passed in.

```go
fmt.Printf("My weight on the surface of %v is %v lbs.\n", "Earth", 154.0)
```

`Printf` can also handle text alignment. Specify a width as part of the format verb,
like `%4v` to pad a value to a width of 4 characers. Positive numbers align with
spaces on the left, negative numbers align with spaces on to the right.

```go
fmt.Printf("%-15v $%4v\n", "SpaceX", 94)
fmt.Printf("%-15v $%4v\n", "Virgin Galactic", 100)

// output:
// SpaceX          $  94
// Virgin Galactic $ 100
```

## Constants and Variables

We've done calculations on literal numbers, but that's not very intuitive. So,
we'll use constants and variables to make it more so.

```go
package main

import "fmt"

func main() {
  const lightspeed = 299792
  var distance = 56000000

  fmt.Println(distance/lighspeed, "seconds")

  distance = 401000000
  fmt.Println(distance/lightSpeed, "seconds")
}

// 186 seconds
// 1337 seconds
```

## Taking a Shortcut

You can declare variables and constants in different manners.

```go
// individually
var distance = 56000000
var speed = 100800

// as a group
var (
    distance = 56000000
    speed = 100800
)

// on a single line
var distance, speed = 56000000, 100800
```

### Increment and Assignment Operators

Standard support for `+=`, `++`, `--`, `*=`, et al.

### Think of a Number

Random number generation is straightforward, as well.

```go
package main

import (
    "fmt"
    "math/rand"
)

func main() {
    var num = rand.Intn(10) + 1
    fmt.Println(num)

    num = rand.Intn(10) + 1
    fmt.Println(num)
}
```

[🔙 Get Ready, Get Set, Go][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Loops and Branches 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch01-get-ready-get-set-go.md
[upcoming-chapter]: ch03-loops-and-branches.md

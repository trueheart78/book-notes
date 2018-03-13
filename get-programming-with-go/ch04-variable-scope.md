[🔙 Loops and Branches][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Capstone: Ticket to Mars 🔜][upcoming-chapter]

# Chapter 4. Variable Scope

## Looking Into Scope

In Go, scoping tends to begin and end along the lines of curly braces `{}`.


```go
ipackage main

import (
    "fmt"
    "math/rand"
)

func main() {
    var count = 0 // you can't access this outside of main

    for count < 10 {
        var num = rand.Intn(10) + 1
        fmt.Println(num)

        count++
    }
}
```

## Short Declaration

That `var` keyword isn't always necessary. The following lines are equivalent.

```go
var count = 10
count := 10
```

You can use this to make `for` loops better.

```go
for count := 10; count > 0; count-- {
  fmt.Println(count)
}
```

Short declarations also make it possible to declare a new variable in an `if`
statement. In the following, `num` can be used anywhere within the `if...else`.

```go
if num := rand.Intn(3); num == 0 {
    fmt.Println("Space Adventures")
} else if num == 1 {
    fmt.Println("SpaceX")
} else {
    fmt.Println("Virgin Galactic")
}
```

You can also make it as part of a `switch` statement.

```go
switch num := rand.Intn(10); num {
case 0:
    fmt.Println("Space Adventures")
case 1:
    fmt.Println("SpaceX")
case 2:
    fmt.Println("Virgin Galactic")
default:
    fmt.Println("Random spaceline #", num)
}
```

💡 Tip: Short declaration is not available for variables declared at the package
scope (ie: outside of functions).

## Narrow Scope, Wide Scope

The following demonstrates several different scopes in Go, and why it is
important to consider scope when declaring variables.

```go
import (
    "fmt"
    "math/rand"
)

var era = "AD" // available everywhere

func main() {
    year := 2016 // available in main()

    switch month := rand.Intn(12) + 1; month { // available in if...else
    case 2:
        day := rand.Intn(29) + 1 // available in this case only
        fmt.Println(era, year, month, day)
    case 4, 6, 9, 11:
        day := rand.Intn(30) + 1 // available in this case only
        fmt.Println(era, year, month, day)
    default:
        day := rand.Intn(31) + 1 // available in this case only
        fmt.Println(era, year, month, day)
    }
}
```

Let's refactor the above.

```go
package main

import (
    "fmt"
    "math/rand"
)

var era = "AD"

func main() {
    year := 2016
    month := rand.Intn(12) + 1
    daysInMonth := 31

    switch month {
    case 2:
        daysInMonth = 29
    case 4, 6, 9, 11:
        daysInMonth = 30
    }

    day := rand.Intn(daysInMonth) + 1
    fmt.Println(era, year, month, day)
}
```

[🔙 Loops and Branches][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Capstone: Ticket to Mars 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch03-loops-and-branches.md
[upcoming-chapter]: ch05-capstone-ticket-to-mars.md

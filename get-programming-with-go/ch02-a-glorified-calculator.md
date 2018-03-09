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


[🔙 Get Ready, Get Set, Go][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Loops and Branches 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch01-get-ready-get-set-go.md
[upcoming-chapter]: ch03-loops-and-branches.md

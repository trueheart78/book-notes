[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Names 🔜][upcoming-chapter]

# Chapter 8. Loose Ends

There's a lot more to Go than what is covered in this wonderful set of tutorials.
Here's some quick and dirty topics worth touching on.

**Control flow:** There is the `if` and the `for` statements, but there is also the
`switch` statement. 

```go
switch coinflip() {
case "heads":
    heads++
case "tails":
    tails++
default:
    fmt.Println("landed on edge!")
}
```

The result of calling `conflip` is compared to the value of each case, and cases are
evaluated from top to bottom. The default case (_optional_) is selected if no other cases match.
ALso of not, _unlike C-like languages_, **cases do not fall through**. There is _no missing break
statements_.

Also, a `switch` doesn't need an operand; it can just list the cases, each of which is a boolean
expression:

```go
func Signum(x int) int {
    switch {
    case x > 0:
        return +1
    default:
        return 0
    case x < 0:
        return -1
    }
}
```

This form is called a _tagless switch_; it's equivalent to `switch true`.

Like the `for` and `if` statements, a `switch` may include an optional simple staement (a short
variable declaration, an increment or assignment statement, or a function call) that can be used
to set a value before it is tested.

The `break` and `continue` statements modify control-flow. A `break` breaks out of the `for`,
`switch` or `select` statement, and a `continue` skips to the next iteration of the loop.

[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Names 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch007-a-web-server.md
[upcoming-chapter]: ch009-names.md

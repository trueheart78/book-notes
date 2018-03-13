[🔙 Capstone: Ticket to Mars][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Whole Numbers 🔜][upcoming-chapter]

# Chapter 6. Real Numbers

Computers store and manipulate real numbers like 3.14159 using the IEEE-754 _floating point_
standard. They can range from miniscule to massive.

## Declaring Floating Point Variables

Every variable has a type. The following three lines of code are equivalent.

```go
days := 365.2425
var days = 365.2425
var days float64 = 365.2425
```

It's nice to know that `days` is a `float64` type, but it is unnecessary to specify
it. 

💡 Tip: The `golint` tool provides hints for coding styles.

If you initialize a variable with a whole number, Go will think you want an integer,
unless you tell it otherwise.

```go
var answer float64 = 42
```

## Single Precision Floating Point Numbers

Go actually has two floating point types, `float64` (considered a _double
precision_ float). There is also `float32`, which uses half the memory, but
also comes with half the precision (a _single precision_ float).

If you want a `float32`, you have to tell Go.

```go
var pi64 = math.Pi
var pi32 float32 = math.Pi

fmt.Println(pi64)
fmt.Println(pi32)

// 3.141592653589793
// 3.1415927
```

When working with a large amount of data, like vertices in a 3D game, it may make
sense to sacrifice precision for memory savings with `float32`.

💡 Tip: Functions in the `math` package operate on `float64` types, so prefer those
unless you have good reason not to.

## The Zero Value

In Go, each type has a default value, called the _zero value_. This applies when
you don't initialize a variable with a value.

```go
var price float64
fmt.Println(price)

// 0
```

## Displaying Floating Point Types

When using `Print` or `Println`, the default behavior for floating point types
is to display as many digits as possible. Use `Printf` with `%f` to specify the
number of digits.

```go
third := 1.0 / 3
fmt.Println(third)
fmt.Printf("%v\n", third)
fmt.Printf("%f\n", third)
fmt.Printf("%.3f\n", third)
fmt.Printf("%4.2f\n", third)

// 0.3333333333333333
// 0.3333333333333333
// 0.333333
// 0.333
// 0.33
```

The `%f` verb formats the value of `third` with a _width_ and _precision_.

![percent f verb][percent-f-verb]

Width specifies the minimum number of characters to display, including the decimal
point and the digits before and after it. 

To left pad with zeros instead of spaces, simply prefix with a zero.

```go
fmt.Printf("%05.2f\n", third)

// 00.33
```

## Floating Point Accuracy

_Skipped, but may come back_

[🔙 Capstone: Ticket to Mars][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Whole Numbers 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch05-capstone-ticket-to-mars.md
[upcoming-chapter]: ch07-whole-numbers.md
[percent-f-verb]: images/ch06-percent-f-verb.png

[🔙 Interface Satisfaction][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Interface Values 🔜][upcoming-chapter]

# Chapter 47. Parsing Flags with flag Value

Let's look at `flag.Value` now.

```go
// gopl.io/ch7/sleep
var period = flag.Duration("period", 1*time.Second, "sleep period")

func main() {
    flag.Parse()
    fmt.Printf("Sleeping for %v...", *period)
    time.Sleep(*period)
    fmt.Println()
}
```

Before it goes to sleep it prints the time period. The `fmt` pkg calls the `time.Duration`'s 
`String` method to print the period not as a number of nanoseconds, but in a user-friendly notation:

```
$ go build gopl.io/ch7/sleep
$ ./sleep
Sleeping for 1s...
```

Now let's control the sleep duration through the `-period` flag. The `flag.Duration` fn creates a
flag var of type `time.Duration` and allows the user to specifiy the duration in a variety of user-
friendly formats.

```
$ ./sleep -period 50ms
Sleeping for 50ms...
$ ./sleep -period 2m30s
Sleeping for 2m30s...
$ ./sleep -period 1.5h
Sleeping for 1h30m0s...
$ ./sleep -period "1 day"
invalid value "1 day" for flag -period: time: invalid duration 1 day
```

Because duration-valued flags are so useful, this feature is built into the `flag` pkg, but we can
define new notations for our own data types. We just need to satisfy the `flag.Value` interface.

```go
package flag

// Value is the interface to the value stored in a flag.
type Value interface {
    String() string
    Set(string) error
}
```

The `String` method formats the flag's value for use in cli help messages, thus every `flag.Value`
is also a `fmt.Stringer`. The `Set` method parses its string arg and updates the flag value.
The `Set` method is the inverse of the `String` method, and its good practice for them to use the
same notation.

Let's define a `celsiusFlag` type that allows a temp to specified in Celsius, or in Faranheit with
an appropriate conversion. Notice that `celsiusFlag` embeds a `Celsius`, thereby getting a `String`
method for free. So, to satisfy `flag.Value`, we need only declare the `Set` method.

```go
// *celsiusFlag satisfies the flag.Value interface.
type celsiusFlag struct{ Celsius }

func (f *celsiusFlag) Set(s string) error {
    var unit string
    var value float64
    fmt.Sscanf(s, "%f%s", &value, &unit) // no error check needed
    switch unit {
    case "C", "°C":
        f.Celsius = Celsius(value)
        return nil
    case "F", "°F":
        f.Celsius = FToC(Fahrenheit(value))
        return nil
    }
    return fmt.Errorf("invalid temperature %q", s)
}
```

The call to `fmt.Sscanf` parses a floating-point number (`value`) and a string (`unit`) from the
input `s`. Although one must usually check `Sscanf`'s err result, in this case we don't need to
because if there was a problem, we'd have no match.

The `CelsiusFlag` fn below wraps it all up.

```go
// CelsiusFlag defines a Celsius flag with the specified name,
// default value, and usage, and returns the address of the flag variable.
// The flag argument must have a quantity and a unit, e.g., "100C".
func CelsiusFlag(name string, value Celsius, usage string) *Celsius {
    f := celsiusFlag{value}
    flag.CommandLine.Var(&f, name, usage)
    return &f.Celsius
}
```

Now we can start using the new flag ourselves:


```go
var temp = tempconv.CelsiusFlag("temp", 20.0, "the temperature")
func main() {
    flag.Parse()
    fmt.Println(*temp)
}
```

Here's a typical session:

```
$ go build gopl.io/ch7/tempflag
$ ./tempflag
20°C
$ ./tempflag -temp -18C
-18°C
$ ./tempflag -temp 212°F
100°C
$ ./tempflag -temp 273.15K
invalid value "273.15K" for flag -temp: invalid temperature "273.15K"
Usage of ./tempflag:
  -temp value
        the temperature (default 20°C)
$ ./tempflag -help
Usage of ./tempflag:
  -temp value
        the temperature (default 20°C)<Paste>
```

## Exercises

**Exercise 7.6:** Add support for Kelvin temperatures to `tempFlag`.

**Exercise 7.7:** Explain why the help message contains `°C` when the default value of `20.0`
does not.

[🔙 Interface Satisfaction][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Interface Values 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch046-interface-satisfaction.md
[upcoming-chapter]: ch048-interface-values.md

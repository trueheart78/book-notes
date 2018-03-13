[🔙 Multilingual Text][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Capstone: The Vigenère Cipher 🔜][upcoming-chapter]

# Chapter 10. Converting Between Types

## Types Don't Mix

If you try to join a number with a string, the Go compiler will report an error.

```go
countdown := "Launch in T minus " + 10 + " seconds"

// invalid operation: mismatched types string and int
```

Even math that works in other languages will cause errors in Go.

```go
age := 40
marsDays := 687
earthDays := 365.2425
fmt.Println("I am", age*earthDays/marsDays, "years old on Mars.")

// invalid operation: mismatched types
```

Make `age` and `marsDays` into floating points, and it would run just fine.

## Numeric Type Conversions

It's not tricky.

```go
age := 40
newAge := float64(age)
```

Variables of diffrent types don't mix, but with type conversion, the world is your
oyster!

```go
age := 40
newAge := float64(age)

marsDays := 687.0
earthDays := 365.2425
fmt.Println("I am", newAge*earthDays/marsDays, "years old on Mars.")

// I am 21.265938864628822 years old on Mars.
```

Converting from a floating point to an integer causes the digits after the
decimal to be truncated, without rounding (another option).


```go
fmt.Println(int(earthDays))

// 365
```

## Convert Types with Caution

It can cause catastrophic issues if you are working with delicate data, like
flight data.

The Arianne 5 rocket exploded in 1996 just 40 seconds after take-off because
of a float to int conversion that caused instrument malfunction.

```go
var bh float64 = 32767
var h = int16(bh)
fmt.Println(h)
```

If the value of `bh` is greater than what `int16` can hold, it wraps around, and
becomes the lowest possible number for an `int16`, -32768.

The rocket used the Ada language, so that when this conversion occurred, an
out-of-range value caused a software exception.

To detect if converting a type to `int16` will result in an invalid value, the
`math` package provides `Min`/`Max` constants.

```go
if bh < math.MinInt16 || bh > math.MaxInt16 {
      // handle out of range value
}
```

## String Conversions

_Continuing from here_.


[🔙 Multilingual Text][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Capstone: The Vigenère Cipher 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch09-multilingual-text.md
[upcoming-chapter]: ch11-capstone-the-vigen-re-cipher.md

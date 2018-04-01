[🔙 Go Packages, Algorithms, and Data Structures][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[File Input and Output 🔜][upcoming-chapter]

# Chapter 5. Files and Directories

## Useful Packages

The single most important package that will help in file interactions and manipulation is the
[`os` pkg][pkg/os]. 

There is also the [`flag` pkg][pkg/flag], which lets you define and process your own flags and
manipulate the command-line args of a program.

The [`filepath` pkg][pkg/filepath] is also extremely handy, as it includes the `filepath.Walk()`
fn that allows you to traverse directory structures in an easy way.

## Command-Line Arguments Revisited!

### The `flag` Package

The [`flag` pkg][pkg/flag] does the dirty work of parsing command-line args and options for us,
and lets us worry about other code. It also supports various types of params, including strings,
ints, and booleans, so you don't have to do any type conversions.

Let's take a look at the `useingFlag.go` program:


```go
package main

import (
  "flag"
  "fmt"
)

func main() {
  // we're defining flags here, which default to false
  minusO := flag.Bool("o", false, "o")
  minusC := flag.Bool("c", false, "c")
  // except for this one, that requires an int
  minusK := flag.Int("k", 0, "an int")

  // parse the flags, as this will raise an error if an unsupported flag is passed in
  flag.Parse()

  // output the values of the flags - reminder they are addresses aka pointers
  fmt.Println("-o:", *minusO)
  fmt.Println("-c:", *minusC)
  fmt.Println("-k:", *minusK)

  // access the unused arguments passed in
  for index, val := range flag.Args() {
    fmt.Println(index, ":", val)
  }
}
```

Here's an example of the output:

```
$ gru usingFlag.go -o -k 12 1 2 3

-o: true
-c: false
-k: 12
0 : 1
1 : 2
2 : 3
```

If you forget to type the value of a command-line option (`-k`) or the provided value is not the
correct type, you'll get the following messages:


```
$ go run usingFlag.go -k

flag needs an argument: -k
Usage of ./usingFlag.go:
  -c  c
  -k int
      an int
  -o  o

$ go run usingFlag.go -k=abc

invalid value "abc" for flag -k: strconv.ParseInt: parsing "abc": invalid syntax
Usage of ./usingFlag.go:
  -c  c
  -k int
      an int
  -o  o
```

If you dont' want your program to exit on parse error, use the `ErrorHandling` type provided by
the [`flag` pkg][pkg/flag]. This allows you to change the way `flag.Parse()` behaves on errors
with the help of the `NewFlagSet()` fn.

## Dealing with Directories

_Coming back to this_

_Coming back to this_

### About Symbolic Links

### Implementing the `pwd(1)` Command

### Developing the `which(1)` Utility

#### Printing the Permission Bits

## Dealing with Files

### Deleting a File

### Renaming and Moving Files

## Developing `find(1)`

### Traversing a Directory Tree

#### Visiting Directories Only!

## The First Version of `find(1)`

### Adding Some Command-Line Options

### Excluding Filenames From the Output

### Excluding a File Extension From the Output

## Using Regular Expressions

### Creating a Copy of a Directory Structure

[🔙 Go Packages, Algorithms, and Data Structures][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[File Input and Output 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch04-go-packages-algorithms-and-data-structures.md
[upcoming-chapter]: ch06-file-input-and-output.md
[pkg/os]: https://golang.org/pkg/os/
[pkg/flag]: https://golang.org/pkg/flag/
[pkg/filepath]: https://golang.org/pkg/filepath/

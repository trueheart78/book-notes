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

### Printing Output

## Go Functions

## Go Data Structures

## Interfaces

## Creating Random Numbers

[🔙 Getting Started with Go and Unix Systems Programming][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Advanced Go Features 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch01-getting-started-with-go-and-unix-systems-programming.md
[upcoming-chapter]: ch03-advanced-go-features.md
[pkg/fmt]: https://golang.org/pkg/fmt/

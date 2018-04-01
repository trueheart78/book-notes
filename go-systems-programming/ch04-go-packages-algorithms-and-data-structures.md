[🔙 Advanced Go Features][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Files and Directories 🔜][upcoming-chapter]

# Chapter 4. Go Packages, Algorithms, and Data Structures

## About Algorithms

### Big O

Big O notation is for describing algorithm complexity. `O(n)`, where n is the size of the input, 
is considered better than `O(n²)`, and so on. Watch out for `O(n!)` because they are unusable for 
all  but tiny element sizes.

Try and use the built-in types when dealing with algorithms, as they have been tuned to obtain a
`O(1)`. Also, array operations are faster than map operations, whereas maps are more versatile.

## Sorting Algorithms

* **Quicksort:** One of the fastest sorting algorithms. Average time is `O(n log n)`, but can
grow up to `O(n²)`
* **Bubble sort:** Easy to implement with an `O(n²)` avg complexity. This is a good place to start.

### `sort.Slice()`

In Go 1.8, `sort.Slice()` appeared. Let's see it in `sortSlice.go`:

```go
package main

import (
  "fmt"
  "sort"
)

type aStructure struct {
  person string
  height int
  weight int
}

func main() {
  // create a slice of aStructures
  mySlice := make([]aStructure, 0)

  a := aStructure{"Mihalis", 180, 90}
  mySlice = append(mySlice, a)

  a = aStructure{"Dimitris", 180, 95}
  mySlice = append(mySlice, a)

  a = aStructure{"Marietta", 155, 45}
  mySlice = append(mySlice, a)

  a = aStructure{"Bill", 134, 40}
  mySlice = append(mySlice, a)

  fmt.Println("0:", mySlice)

  sort.Slice(mySlice, func(i, j int) bool {
    // define how you want to sort the slice and 💥
    return mySlice[i].weight < mySlice[j].weight
  })

  fmt.Println("<:", mySlice)

  sort.Slice(mySlice, func(i, j int) bool {
    // define how you want to sort the slice and 💥
    return mySlice[i].weight > mySlice[j].weight
  })

  fmt.Println(">:", mySlice)
}
```

Output will be:

```
0: [{Mihalis 180 90} {Dimitris 180 95} {Marietta 155 45} {Bill 134 40}]
<: [{Bill 134 40} {Marietta 155 45} {Mihalis 180 90} {Dimitris 180 95}]
>: [{Dimitris 180 95} {Mihalis 180 90} {Marietta 155 45} {Bill 134 40}]
```

If your Go version is below 1.8, you'll see something akin to:

```
$ go version
go version go1.3.3 linux/amd64
$ go run sortSlice.go
# command-line-arguments
./sortSlice.go:27: undefined: sort.Slice
./sortSlice.go:31: undefined: sort.Slice
```

## Linked Lists

_Skipped for now._

## Trees

_Skipped for now._

## Developing a Hash Table

_Skipped for now._

## About Packages

Packages are for grouping related functions and constants to make them portable and use them in
multiple Go programs. Aside from the `main` package, packages are not autonomous programs.

### Using Standard Packages

You can see a full list at the [Go Packages page][pkgs]. You can also use the `godoc` utility
(example: `godoc net`).

### Creating Your Own Packages

Packages make the design, implementation, and maintenance of large software systems easier and
simpler. They also allow multiple devs to work on the same project without an overlapping. So if
you find yourself reusing the same fns frequently, consider including them in your own packages.

The source code of a package(which can have multiple files) can be found in a single dir, named
after the package (except for the `main` package).

Here's `aSimplePackage.go` file:

```go
package aSimplePackage

import (
  "fmt"
)

// capitalization means the consts, vars, fns, etc are exported when the package is imported
const Pi = "3.14159"

func Add(x, y int) int {
  return x + y
}

func Println(x int) {
  fmt.Println(x)
}
```

Installing it, it should be in its own directory in `~/go/src/aSimplePackage`, and then you can
install it by running `go install aSimplePackage`. 

💡 _You should get into the habit of installing packages you write._

Where does it end up? On macOS, we can see it in the `~/go/pkg` directory:

```
$ tree ~/go/pkg/darwin_amd64 
/Users/jmills/go/pkg/darwin_amd64
└── aSimplePackage.a
```

### Private Variables and Functions

Go follows a simple rule that states that fns, vars, types, etc, that begin with an uppercase
letter are public, and those that begin with a lowercase letter are private.

### The `init()` Function

Every package can have a fn named `init()` that is automatically executed at the beginning of the
execution. 

```go
func init() {
  fmt.Println("The init fn of my package")
}
```

There are times where you need to perform important initializations before you start using a pkg,
like opening a db or network connection; that's where this fn shines.

### Using Your Own Packages

Just import it!

```go
package main

import (
  "aSimplePackage"
  "fmt"
)

func main() {
  temp := aSimplePackage.Add(5, 10)
  fmt.Println(temp)

  fmt.Println(aSimplePackage.Pi)
}
```

If it's compiled and available, it should not cause an issue. If it is not, then you'll get a
`cannot find package` error.

### Using External Packages

Sometimes pkgs are on the internet and its better to reference them by using their address, so
let's see how that works for a `MySQL` driver in `useMySQL.go`:

```go
package main

import (
  "fmt"
    _ "github.com/go-sql-driver/mysql"
    )

func main() {
    fmt.Println("Using the MySQL Go driver!")
}
```

Try running it and you should see the following (unless you've already installed it):

```
$ go run useMySQL.go
useMySQL.go:5:2: cannot find package "github.com/go-sql-driver/mysql" in any of:
  /usr/local/Cellar/go/1.10/libexec/src/github.com/go-sql-driver/mysql (from $GOROOT)
    /Users/jmills/programming/go/src/github.com/go-sql-driver/mysql (from $GOPATH)
```

So we need to get it. Literally.

```
$ go get github.com/go-sql-driver/mysql
$ go run useMySQL.go
Using the MySQL Go driver!
```

And you will now have it in your `~/go/pkg/` directory, but you'll also have the source code, too.
You will find it in `~/go/src/github.com/go-sql-driver/mysql`:

```
$ ls ~/go/src/github.com/go-sql-driver/mysql
AUTHORS                 dsn.go
CHANGELOG.md            dsn_test.go
CONTRIBUTING.md         errors.go
LICENSE                 errors_test.go
README.md               fields.go
appengine.go            infile.go
benchmark_go18_test.go  packets.go
benchmark_test.go       packets_test.go
buffer.go               result.go
collations.go           rows.go
connection.go           statement.go
connection_go18.go      statement_test.go
connection_go18_test.go transaction.go
connection_test.go      utils.go
const.go                utils_go17.go
driver.go               utils_go18.go
driver_go18_test.go     utils_go18_test.go
driver_test.go          utils_test.go
```

#### The `go clean` Command

There will be times you are developing a Go program that uses lots of nonstandard pkgs and you
want to start the compilation process from the beginning. You can clean up the files of a pkg in
order to recreate it later. 

To clean up a pkg without affecting its code:

```
$ go clean -x -i aSimplePackage

cd /Users/jmills/programming/go/src/aSimplePackage
rm -f aSimplePackage.test aSimplePackage.test.exe
rm -f /Users/jmills/programming/go/pkg/darwin_amd64/aSimplePackage.a
```

You can also clean up a pkg you have downloaded from the web.

```
$ go clean -x -i github.com/go-sql-driver/mysql

cd /Users/jmills/programming/go/src/github.com/go-sql-driver/mysql
rm -f mysql.test mysql.test.exe appengine appengine.exe utils_go17 utils_go17.exe
rm -f /Users/jmills/programming/go/pkg/darwin_amd64/github.com/go-sql-driver/mysql.a
```

💡 _go clean is useful when you want to transfer your projects to another machine without
including unnecessary files._

## Garbage Collection

Freeing unused memory is the GC's job. Let's look at `garbageCol.go`:

```go
package main

import (
  "fmt"
  "runtime"
  "time"
)

func printStats(mem runtime.MemStats) {
  runtime.ReadMemStats(&mem)
  fmt.Println("mem.Alloc:", mem.Alloc)
  fmt.Println("mem.TotalAlloc:", mem.TotalAlloc)
  fmt.Println("mem.HeapAlloc:", mem.HeapAlloc)
  fmt.Println("mem.NumGC:", mem.NumGC)
  fmt.Println("-----")
}

func main() {
  var mem runtime.MemStats
  printStats(mem)

  // use memory to trigger the GC
  for i := 0; i < 10; i++ {
    s := make([]byte, 100000000)
    if s == nil {
      fmt.Println("Operation failed!")
    }
  }
  printStats(mem)

  // use more memory to trigger the GC
  for i := 0; i < 10; i++ {
    s := make([]byte, 100000000)
    if s == nil {
      fmt.Println("Operation failed!")
    }
    time.Sleep(5 * time.Second)
  }
  printStats(mem)

}
```

Everytime you want to read the latest memory sats, make a call to `runtime.ReadMemStats()`.

It takes a hot minute to run, but here's what you may see:

```
mem.Alloc: 68792
mem.TotalAlloc: 68792
mem.HeapAlloc: 68792
mem.NumGC: 0
-----
mem.Alloc: 100075904
mem.TotalAlloc: 1000150704
mem.HeapAlloc: 100075904
mem.NumGC: 10
-----
mem.Alloc: 72856
mem.TotalAlloc: 2000235808
mem.HeapAlloc: 72856
mem.NumGC: 20
-----
```

This output presents info about properties related to the memory used. If you want even more
details, you can try this:

```
$ GODEBUG=gctrace=1 go run garbageCol.go
```

This will provide you tracing details for the GC.

## Your Environment

Let's look at looking at the OS and Go version in `runtime.go`:

```go
package main

import (
  "fmt"
  "runtime"
)

func main() {
  fmt.Print("You are using ", runtime.Compiler, " ")
  fmt.Println("on a", runtime.GOARCH, "machine")
  fmt.Println("with Go version", runtime.Version())
  fmt.Println("Number of Goroutines:", runtime.NumGoroutine())
}
```

On macOS you will see the following:

```
You are using gc on a amd64 machine
with Go version go1.8
Number of Goroutines: 1
```

On a Linux version on an older version of Go shows the following:

```
You are using gc on a amd64 machine
with Go version go1.3.3
Number of Goroutines: 4
```

## Update Your Go Install Regularly

Go gets updated on the regular, so make a note to check for newer versions.

[🔙 Advanced Go Features][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Files and Directories 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch03-advanced-go-features.md
[upcoming-chapter]: ch05-files-and-directories.md
[pkgs]: https://golang.org/pkg/

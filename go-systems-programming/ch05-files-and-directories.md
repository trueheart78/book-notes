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
Directories allow you to create a structure and store your files in a way that is easy for you to
organize and search for them. In reality, theay are just entries on a filesystem that contain lists
of other files and directories. This happens with the help of **inodes**, which are data structs that
hold info about files and directories.

Directories are implemented as lists of names assigned to inodes. As a result, a directory contains an
entry for itself, it's parent directory, and each of its children, which (among other things) can be
regular files or directories.

💡 _What you should remember is that an inode holds metadata about a file, not the actual data of a 
file._

### About Symbolic Links

**Symbolic links** are pointers to files or directories, which are resolved at the time of access.
Symbolic links (also called _soft links_), are not equal to the file or the directory they are
pointing to, and are allowed to point to nowhere, too.

Here's `symbLink.go`, where we check if a provided path is a symbolic link:


```go
package main

import (
  "fmt"
  "os"
  "path/filepath"
)

func main() {
  arguments := os.Args
  if len(arguments) == 1 {
    fmt.Println("Please provide a file or directory path as a argument!")
    os.Exit(1)
  }
  filename := arguments[1]
  fileinfo, err := os.Lstat(filename)
  if err != nil {
    fmt.Println(err)
    os.Exit(1)
  }

  if fileinfo.Mode()&os.ModeSymlink != 0 {
    fmt.Println(filename, "is a symbolic link")
    realpath, err := filepath.EvalSymlinks(filename)
    if err == nil {
      fmt.Println("Real Path:", realpath)
    }
  }
}
```

This code gets a bit cryptic, as it uses lower-level functions. The technique for finding out if a
path is real or not involves the use of `os.Lstat()`, which gives you info about a file or dir, and
the use of the `Mode()` fn on the return value of the `os.Lstat()` fn call in order to compare
the outcome with the `os.ModeSymlink` constant, which is the symbolic link bit.

There also is the `filepath.EvalSymlinks()` fn that allows us to eval any symlink that exists and
return the true path of it. This might make you thin we're using lots of Go code for a simple task,
but in these instances, it is required.


```
go run symbLink.go /etc
/etc is a symbolic link
Path: /private/etc
```

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

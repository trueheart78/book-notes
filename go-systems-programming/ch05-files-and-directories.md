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

The `pwd(1)` cli tool is simplistic, but does its job quite well. It is handy when you want to get
the full path of a file or dir that resides in the same dir as the script being executed.

```go
package main

import (
  "fmt"
  "os"
  "path/filepath"
)

func main() {
  arguments := os.Args

  pwd, err := os.Getwd()
  if err == nil {
    fmt.Println(pwd)
  } else {
    fmt.Println("Error:", err)
  }

  // at this point, return unless we have an arg that is '-P'
  if len(arguments) == 1 {
    return
  }
  if arguments[1] != "-P" {
    return
  }

  // print the symlinked path if -P was the first arg and the dir is symlinked
  fileinfo, err := os.Lstat(pwd)
  if fileinfo.Mode()&os.ModeSymlink != 0 {
    realpath, err := filepath.EvalSymlinks(pwd)
    if err == nil {
      fmt.Println(realpath)
    }
  }
}
```

Note that if the curr dir can be described by multiple paths (which can happen with symlinks),
`os.Getwd()` can return any one of them. You also need to re-use some of the `symbLink.go` code here,
as we need to discover the physical current working directory incase the `-P` option is given and
you are dealing with a dir that is a symlink. We could also use the [`flag` pkg][pkg-flag]  here,
but it is not necessary.

Example output:

```
$ go run pwd.go
/Users/mtsouk/Desktop/goBook/ch/ch5/code
```

On macOS machines, `/tmp` is a symlink, so if we run it there, it will display the following:

```
$ go run pwd.go
/tmp
$ go run pwd.go -P
/tmp
/private/tmp
```

### Developing the `which(1)` Utility

The `which(1)` utility searches the value of the `PATH` environment var to find out if an executable
file can be found in one of the directories of the `PATH` variable. It works like this:

```
$ echo $PATH
/home/mtsouk/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games

$ which ls
/home/mtsouk/bin/ls

$ which -a ls
/home/mtsouk/bin/ls
/bin/ls
```

Our implementation will support the two options supported by the macOS version of `which(1)`, `-a` and
`-s`, and we'll use the [`flag` pkg][pkg-flag]; the Linux version of `which(1)` does not support the
`-s` option. The `-a` option lists all of the instances of the executable, instead of just the first,
while `-s` returns 0 if the exe was found and `1` otherwise; it's not the same as printing `0` or `1`
using the `fmt` pkg.

To check the return value of a unix command, do the following:

```
$ which -s ls
$ echo $?
0
```

So let's get the `which.go` code down:

```go
package main

import (
  "flag"
  "fmt"
  "os"
  "strings" // used for splitting the PATH environment var
)

func main() {
  // define the flags, and default them to false
  minusA := flag.Bool("a", false, "a")
  minusS := flag.Bool("s", false, "s")

  flag.Parse()
  flags := flag.Args()
  if len(flags) == 0 {
    fmt.Println("Please provide an argument!")
    os.Exit(1)
  }
  file := flags[0]
  found := false

  // load the PATH env var and split it
  path := os.Getenv("PATH")
  pathSlice := strings.Split(path, ":")
  for _, directory := range pathSlice {
    fullPath := directory + "/" + file
    // find out if it exists using os.Stat
    fileInfo, err := os.Stat(fullPath)
    if err == nil {
      // check the mode to see if it is a regular file, as we're not looking for symlinks or dirs
      mode := fileInfo.Mode()
      if mode.IsRegular() {
        if mode&0111 != 0 {
          found = true
          if *minusS == true { // notice the check against the pointer
            os.Exit(0)
          }
          if *minusA == true { // notice the check against the pointer
            fmt.Println(fullPath)
          } else {
            fmt.Println(fullPath)
            os.Exit(0)
          }
        }
      }
    }
  }
  // if it isn't found, exit with a status code of 1
  if found == false {
    os.Exit(1)
  }
}
```

Here, the call to `os.Stat()` tells whether the file we are looking for exists or not. When it does,
the `mode.IsRegular()` fn checks if its a regular file. Then, we perform a test to find out if the
file found was executable: if it isn't, it won't get printed. So the `if mode&0111 != 0` statement
verifies the file is actually runnable.

Next, if the `-s` flag is set to `*minusS == true`, the `-a` flag doesn't matter.

As you can see, there are lots of checks here, which is not rare for systems software. Regardless, you
should always examplime all possibilities to avoid surprises later. The good thing is that most of the
checks will be used later on in the Go implementation of `find(1)`: it is good practice to test some
features by writing small aps before putting them altogether into a bigger app, so you can learn the
technique and are readily aware of potential gotchas.

Executing `which.go` will produce:

```
$ go run which.go ls
/home/mtsouk/bin/ls
$ go run which.go -s ls
$ echo $?
0
$ go run which.go -s ls123123
exit status 1
$ echo $?
1
$ go run which.go -a ls
/home/mtsouk/bin/ls
/bin/ls
```

#### Printing the Permission Bits

With the help of the `ls(1)` command, you can find out the permissions of a file:

```
$ ls -l /bin/ls
-rwxr-xr-x  1 root  wheel  38624 Mar 23 01:57 /bin/ls
```

here, we'll look at how to print those permissions using Go in the `permissions.go` file.

```go
package main

import (
  "fmt"
  "os"
)

func main() {
  arguments := os.Args
  if len(arguments) == 1 {
    fmt.Println("Please provide an argument!")
    os.Exit(1)
  }

  file := arguments[1]

  info, err := os.Stat(file)
  if err != nil {
    fmt.Println("Error:", err)
    os.Exit(1)
  }
  mode := info.Mode()
  fmt.Print(file, ": ", mode, "\n")
}
```

Once again, most of the code is for dealing with the cl-args and making sure that one exists.
Using `os.Stat()` does most of the work, so you can use the `FileInfo` struct that describes the
file or dir that was examined. Using `FileInfo.Mode()`, you can get the permy bits.

Example:

```
$ go run permissions.go /bin/ls
/bin/ls: -rwxr-xr-x

$ go run permissions.go /usr
/usr: drwxr-xr-x

$ go run permissions.go /us
Error: stat /us: no such file or directory
exit status 1
```

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

[// if fileSizes was closed🔙// if fileSizes was closed Multiplexing with select][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Cancellation 🔜][upcoming-chapter]

# Chapter 66. Example: Concurrent Directory Traversal

Here, we'll build an app that reports the disk usage of one or more dirs specified on the cli, like
the `du` command in Unix. Most of the work is done by the `walkDir` fn belowe, which enumerates the
entries of the directory `dir` using the `dirents` helper fn.

```go
// gopl.io/ch8/du1
// walkDir recursively walks the file tree rooted at dir
// and sends the size of each found file on fileSizes.
func walkDir(dir string, fileSizes chan<- int64) {
    for _, entry := range dirents(dir) {
        if entry.IsDir() {
            subdir := filepath.Join(dir, entry.Name())
            walkDir(subdir, fileSizes)
        } else {
            fileSizes <- entry.Size()
        }
    }
}

// dirents returns the entries of directory dir.
func dirents(dir string) []os.FileInfo {
    entries, err := ioutil.ReadDir(dir)
    if err != nil {
        fmt.Fprintf(os.Stderr, "du1: %v\n", err)
        return nil
    }
    return entries
}
```

The `ioutil.ReadDir` fn returns a slice of `os.FileInfo`, the same info that a call to `os.Stat` 
returns for a single file. For each subdir, `walkDir` recursively calls itself, and for each file,
it sends a message on the `fileSizes` C. The message is the size of the file in bytes.

The main fn uses two Gs. A background G that calls `walkDir` for each dir specified and finally
closes the `fileSizes` C. The main G computes the sum of the file sizes it receives from the C
and prints the total.

```go
// The du1 command computes the disk usage of the files in a directory.
package main

import (
    "flag"
    "fmt"
    "io/ioutil"
    "os"
    "path/filepath"
)
func main() {
    // Determine the initial directories.
    flag.Parse()
    roots := flag.Args()
    if len(roots) == 0 {
        roots = []string{"."}
    }

    // Traverse the file tree.
    fileSizes := make(chan int64)
    go func() {
        for _, root := range roots {
            walkDir(root, fileSizes)
        }
        close(fileSizes)
    }()

    // Print the results.
    var nfiles, nbytes int64
    for size := range fileSizes {
        nfiles++
        nbytes += size
    }
    printDiskUsage(nfiles, nbytes)
}

func printDiskUsage(nfiles, nbytes int64) {
    fmt.Printf("%d files  %.1f GB\n", nfiles, float64(nbytes)/1e9)
}
```

This program pauses for a long while before printing its result:

```
$ go build gopl.io/ch8/du1
$ ./du1 $HOME /usr /bin /etc
213201 files  62.7 GB
```

The program would be nicer if it kept us informed of progress, but we need to do more than just
move `printDiskUsage` into the loop.

The variant of `du` below prints the totals periodically, but only if the `-v` flag is specified.
The bg G that loops over `roots` remains unchanged. The main G now uses a ticker to generate events
every 500ms, and a select statement to wait for either a file size message, where it then updates
the totals, or a tick event, in which case it prints current totals. If the `-v` flag is not 
specified, the `tick` C remains nil, and the `select` case is effectively disabled.

```go
// gopl.io/ch8/du2
var verbose = flag.Bool("v", false, "show verbose progress messages")

func main() {
    // ...start background goroutine...

    // Print the results periodically.
    var tick <-chan time.Time
    if *verbose {
      tick = time.Tick(500 * time.Millisecond)
    }
    var nfiles, nbytes int64

loop:
    for {
        select {
        case size, ok := <-fileSizes:
            if !ok {         // if fileSizes was closed
                break loop   // break out of the named loop, defined right above the "for"
            }
            nfiles++
            nbytes += size
        case <-tick:
            printDiskUsage(nfiles, nbytes)
        }
    }
    printDiskUsage(nfiles, nbytes) // final totals
}
```

Since the app no longer uses a `range` loop, the first `select` case must test if the `fileSizes`
C has been closed, using the two-result form of receive ops. If it has been closed, it breaks out
of the loop. It uses a labeled `break` statement to bust outta both the `select` and the `for`; an
unlabeled one would have just done the `select`.

Now we get a stream of updates:

```
$ go build gopl.io/ch8/du2
$ ./du2 -v $HOME /usr /bin /etc
28608 files  8.3 GB
54147 files  10.3 GB
93591 files  15.1 GB
127169 files  52.9 GB
175931 files  62.2 GB
213201 files  62.7 GB
```

However, this still takes too long to run. There is no reason why all the calls to `walkDir` can't
be done concurrently, thereby exploiting parallelism in the disk system. Our third version creates
a new G for each call to `walkDir`, using a `sync.Waitgroup` to count the number of Gs that are
still active, and a closer G to close the `fileSizes` C when the counter drops to zero.

```go
// gopl.io/ch8/du3
func main() {
    // ...determine roots...

    // Traverse each root of the file tree in parallel.
    fileSizes := make(chan int64)
    var n sync.WaitGroup
    for _, root := range roots {
        n.Add(1)
        go walkDir(root, &n, fileSizes)
    }
    go func() {
        n.Wait()
        close(fileSizes)
		}()
    // ...select loop...
}

func walkDir(dir string, n *sync.WaitGroup, fileSizes chan<- int64) {
    defer n.Done()
    for _, entry := range dirents(dir) {
        if entry.IsDir() {
            n.Add(1)
            subdir := filepath.Join(dir, entry.Name())
            go walkDir(subdir, n, fileSizes)
        } else {
            fileSizes <- entry.Size()
        }
    }
}
```

Since we are going to create many thousands of Gs, we need to have `dirents` using a counting
semaphore to prevent it from opening too many files at once, just like we did for the web crawler.

```go
// sema is a counting semaphore for limiting concurrency in dirents.
var sema = make(chan struct{}, 20)

// dirents returns the entries of directory dir.
func dirents(dir string) []os.FileInfo {
    sema <- struct{}{}        // acquire token
    defer func() { <-sema }() // release token
    // ...
}
```

This version runs many times faster than the previous one, but there is variablility from system to
system.

## Exercises

* Write a version of `du` that computes and periodically displays separate totals for each of the
`root` directories.

[🔙 Multiplexing with select][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Cancellation 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch065-multiplexing-with-select.md
[upcoming-chapter]: ch067-cancellation.md

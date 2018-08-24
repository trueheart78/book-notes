[🔙 Channels][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Example: Concurrent Web Crawler 🔜][upcoming-chapter]

# Chapter 63. Looping in Parallel

Let's look at concurrency for executing all iterations of a loop in parallel. Consider creating
thumbnails of a set of images. Look at [the thumbnail pkg][thumbnail], and its definition for the
`ImageFile` fn. 

```go
// gopl.io/ch8/thumbnail
package thumbnail

// ImageFile reads an image from infile and writes
// a thumbnail-size version of it in the same directory.
// It returns the generated file name, e.g., "foo.thumb.jpg".
func ImageFile(infile string) (string, error)
```

So what we have now is an app that loops over a list of image file names and creates a thumbnail for
each.

```go
// gopl.io/ch8/thumbnail
// makeThumbnails makes thumbnails of the specified files.
func makeThumbnails(filenames []string) {
    for _, f := range filenames {
        if _, err := thumbnail.ImageFile(f); err != nil {
            log.Println(err)
        }
    }
}
```

The order they get processed doesn't matter, as they are all independent. Problems like this that
consist entirely of subproblems that are completely independent of each other are described as
_embarrassingly parallel_. These are the easiest kind to implement concurrently and enjoy performance
that scales linearly.

Let's make them happen in parallel. First attempt just adds the `go` keyword.

```go
// NOTE: incorrect!
func makeThumbnails2(filenames []string) {
    for _, f := range filenames {
        go thumbnail.ImageFile(f) // NOTE: ignoring errors
    }
}
```

This runs way too fast. Why? Because `makeThumbnails2` returns before it has finished doing what it
was supposed to be doing. It starts all the G, but it doesn't wait for them to finish.

There is no direct way to wait until a G has finished, but we can change the inner G to report its
completion to the outer G by sending an event on a shared C. Since we know the number of files, the
outer G can count that many events before it returns.

```go
// makeThumbnails3 makes thumbnails of the specified files in parallel.
func makeThumbnails3(filenames []string) {
    ch := make(chan struct{})
    for _, f := range filenames {
        go func(f string) { // NOTE: require that we pass in the filename
            thumbnail.ImageFile(f) // NOTE: ignoring errors
            ch <- struct{}{}
        }(f) // NOTE: must pass in "f" else it will use most recent "f"
    }

    // Wait for goroutines to complete.
    for range filenames {
        <-ch
    }
}
```

Here's a bad version that expects a closure to work without realizing we moved on from that 
particular `f` already:

```go
for _, f := range filenames {
    go func() {
        thumbnail.ImageFile(f) // NOTE: incorrect!
        // ...
    }()
}
```

What if we want to return values from each G to the main one? If the call to `thumbnail.ImageFile` 
fails, it returns an error. What would that look like?

```go
// makeThumbnails4 makes thumbnails for the specified files in parallel.
// It returns an error if any step failed.
func makeThumbnails4(filenames []string) error {
    errors := make(chan error)

    for _, f := range filenames {
        go func(f string) {
            _, err := thumbnail.ImageFile(f)
            errors <- err
        }(f)
    }
    for range filenames {
        if err := <-errors; err != nil {
            return err // NOTE: incorrect: goroutine leak!
        }
    }

    return nil
}
```

There is a _very subtle bug_ in the above code: when the first non-`nil` error is encountered, it
returns the error to the caller, leaving no G draining the errors C. Each remaining G will block
_forever_ as it tries to send a value on that C and will never terminate. The G leak can cause
memory exhaustion or the app can become stuck.

So let's try it with a bC, since we do know the number of files. We could also do another G that
drains the C while the main G returns the first error without delay.

So no let's look at how to use a bC to return the names of the new image files, plus errors!

```go
// makeThumbnails5 makes thumbnails for the specified files in parallel.
// It returns the generated file names in an arbitrary order,
// or an error if any step failed.
func makeThumbnails5(filenames []string) (thumbfiles []string, err error) {
    type item struct {
        thumbfile string
        err       error
    }

    ch := make(chan item, len(filenames))
    for _, f := range filenames {
        go func(f string) {
            var it item
            it.thumbfile, it.err = thumbnail.ImageFile(f)
            ch <- it
        }(f)
    }

    for range filenames {
        it := <-ch
        if it.err != nil {
            return nil, it.err
        }
        thumbfiles = append(thumbfiles, it.thumbfile)
    }

    return thumbfiles, nil
}
```

The final version below returns the number of bytes we created, too. However, it now gets filenames
from a bC of strings, so now we don't know the loop count.

To know when the last G has finished (which may not be the last to start), we a counter of sorts for
each G and handle it as each G finishes. This requires one that  can be used conccurrently and safely
so we'll use `sync.WaitGroup`:

```go
// makeThumbnails6 makes thumbnails for each file received from the channel.
// It returns the number of bytes occupied by the files it creates.
func makeThumbnails6(filenames <-chan string) int64 {
    sizes := make(chan int64)
    var wg sync.WaitGroup // number of working goroutines
    for f := range filenames {
        wg.Add(1)
        // worker
        go func(f string) {
            defer wg.Done()
            thumb, err := thumbnail.ImageFile(f)
            if err != nil {
                log.Println(err)
                return
            }
            info, _ := os.Stat(thumb) // OK to ignore error
            sizes <- info.Size()
        }(f)
    }

    // closer
    go func() {
        wg.Wait()
        close(sizes)
    }()

    var total int64
    for size := range sizes {
        total += size
    }
    return total
}
```

Note the asymmetry in the `wg.Add()` and `wg.Done` methods.

Also, the `sizes` C carries each file size back to the main G, which receives them via a `range` loop
and computes the sum. _You could almost see this all as nested loops, but whereas those would use
a `slice`, concurrency requires safety and C's excel at that._ For `sizes`, if we didn't close the C,
then it would enter an endless loop.

[🔙 Channels][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Example: Concurrent Web Crawler 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch062-channels.md
[upcoming-chapter]: ch064-example-concurrent-web-crawler.md
[thumbnail]: https://github.com/adonovan/gopl.io/tree/master/ch8/thumbnail

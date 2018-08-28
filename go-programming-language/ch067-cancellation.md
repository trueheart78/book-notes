[🔙 Example: Concurrent Directory Traversal][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Example: Chat Server 🔜][upcoming-chapter]

# Chapter 67. Cancellation

Sometimes we need to tell a G to stop. Maybe in a web server that is doing something for a client
that has disconnected.

We can't do that directly, since that would leave all its shared vars in undefined states. In the
rocket launch app, we sent a single val on a C named `abort`, which the countdown G interpreted as
a request to stop itself. But what about more than one? What if we don't know how many?

One possibility might be to send as many events on the `abort` C as there are Gs to cancel. If some
of the G have already ended, though, our count will be too large and the sends will get stuck. On
the other hand, if those Gs have spawned other Gs, the count will be too small, and some Gs will
remain post-cancel. So its generally hard to know how many G are working on our behalf at any one
time. For cancellation, what we need is a reliable mechanism to _broadcast_ an event over a C so
that Gs can see it _as_ it occurs and can later see that it _has_ occured.

So after a C has been closed and drained of all sent vals, subsequent receive ops proceed
immediately, yielding zero vals. We can exploit this to create a broadcast mechanism: don't send
a val on the C, _close it_.

We can add a cancellation to the `du` program from the previous section with a few simple changes.
First, we create a cancellation C on which no vals are ever sent, but whose closure indicates that
it is time for the program to stop what it is doing. We also define a utility fn, `cancelled`, that
checks or _polls_ the cancellation state at the instant it is called.

```go
// gopl.io/ch8/du4
var done = make(chan struct{})

func cancelled() bool {
    select {
    case <-done:
        return true
    default:
        return false
    }
}
```

Next, we create a G that reads from std IO, which is generally from a terminal. As soon as any input is read, the cancellation is broadcast by closing the `done` C.

```go
// Cancel traversal when input is detected.
go func() {
    os.Stdin.Read(make([]byte, 1)) // read a single byte
    close(done)
}()
```

Now we need to make our Gs respond to the cancellation. So we add a third case to the `select`
statement that tries to receive from the `done` C. The fn returns if this case is ever selected,
but before it returns it must first drain the `fileSizes` C, discarding all vals until its closed.
It does this to make sure that any active calls to `walkDir` can run to completion without getting
stuck sending to `fileSizes`.

```go
for {
    select {
    case <-done:
        // Drain fileSizes to allow existing goroutines to finish.
        for range fileSizes {
            // Do nothing.
        }
        return
    case size, ok := <-fileSizes:
        // ...
    }
}
```

The `walkDir` G polls the cancellation status when it begins, and returns without doing anything
_if_ the status is set. This turns all Gs created after cancellation into no-ops:

```go
func walkDir(dir string, n *sync.WaitGroup, fileSizes chan<- int64) {
    defer n.Done()
    if cancelled() {
        return
    }
    for _, entry := range dirents(dir) {
        // ...
    }
}
```

It might be profitable to poll the cancellation status again with `walkDir`'s loop, to avoid
creating new Gs post-cancellation. Cancellation involves a trade-off; a quicker response often
requires more intrusive changes to program logic. Ensuring that no expensive ops ever occur post-
cancellation may require updating many places in the code, but often most of the benefit can be
obtained by checking for cancellation in a few important places.

A little profiling of this app revealed that the bottleneck was the acquisition of a semaphore in
`dirents`. The `select` below makes this op cancellable and reduces the typical cancellation
latency of the app from hundreds of milliseconds to tens:

```go
func dirents(dir string) []os.FileInfo {
    select {
    case sema <- struct{}{}: // acquire token
    case <-done:
        return nil // cancelled
    }
    defer func() { <-sema }() // release token

    // ...read directory...
}
```
 Now when cancellation occurs, all the bg Gs quickly stop and the main fn returns. Of course, when
 main returns, a program exists, so it can be hard to tell a main fn that cleans up after itself
 from one that doesn't. We can use a handy trick for testing: if instead of returning from main in
 the even of a cancellation, we execute a call to `panic`, then the runtime will dump the stack of
 every G in the app/ If the main G is all that's left, it's cleaned up after itself. But if other
 Gs remain, there may be issues. The panic dump is usually informational enough to assist during
 these debugging sessions.

## Exercises

* Modify the web crawler to support cancellation. Just use `http.NewRequest` instead of `http.Get`.
* Following the approach of `mirroredQuery`, implement a variant of `fetch` that requests several
URLs concurrently. Once the first one returns, cancel the other requests.

[🔙 Example: Concurrent Directory Traversal][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Example: Chat Server 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch066-example-concurrent-directory-traversal.md
[upcoming-chapter]: ch068-example-chat-server.md

[🔙 Example: Concurrent Echo Server][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Looping in Parallel 🔜][upcoming-chapter]

# Chapter 62. Channels

If G are the activities of a concurrent Go app, then _channels_ (C) are the connections between them.
A C is a communication mechanism that lets one G send values to another G. Each C is a conduit for
vals of a certain type, called the C's _element type_. The type of a C whose elements have type `int`
is written `chan int`.

```go
ch := make(chan int) // ch has type 'chan int'
```

As with maps, a C is a _reference_ to the data structure created by `make`. When we copy a C or pass
one as an arg to a fn, we are copying a reference, so caller and callee refer to the same data 
structure. As with other reference types, the zero value of a C is `nil`.

Two C's of the same type may be compared using `==`. The comparison is true if both are refs to the
same C data structure. A C may be also compared to `nil`.

A C has two principal ops, _send_ and _receive_, collectively known as _communications_. A send
statement transmits a val from one G, through the C, to another G execution a corresponding receive
expression. Bother ops are written using the `<-` operator. In a send statement, the `<-` separates
the C and val operands. In a receive expression, `<-` preceds the C operand. A receive expression
whose result is not used is a valid statement.

```go
ch <- x  // a send statement, from x onto ch

x = <-ch // a receive expression in an assignment statement
<-ch     // a receive statement; result is discarded
```

C's support a third op, _close_, which sets a flag indicating that no more vals will ever be sent on
this C; subsequent attempts to send will panic. Receive ops on a closed C yield the vals that have
been sent until no more vals are left; any receive ops thereafter complete immediately and yield the
zero value of the C's element type.

```go
close(ch)
```

A C created with a simple call to `make` is called _unbuffered_, but `make` accepts an optional
second arg, an int called the C's _capacity_. If the capacity is non-zero, `make` creates a 
_buffered_ channel.

```go
ch = make(chan int)    // unbuffered channel
ch = make(chan int, 0) // unbuffered channel
ch = make(chan int, 3) // buffered channel with capacity 3
```

We'll get to Buffered Channels further down.

## Unbuffered Channels

A send op on a UC blocks the sending G until another G executes a corresponding receive on the same
C, at which point the val is transmitted and both Gs may continue. Conversely, if the receive op was
attempted first, the receiving G is blocked until another G performs a send on the same C.

Communication over a UC causes the sending and receiving Gs to _synchcronize_. Because of this, UC
are sometimes called _synchronous_ (SC). When a val is sent on a UC, the receipt of the val _happens
before_ the reawakening of the sending G.

In discussions of concurrency, when we say _x happens before y_, we don't just mean that _x_ occurs
earlier in time than _y_; we mean that it is guaranteed to do so and that all its prior effects, such
as updates to vars, are complete, and you may rely on them.

When _x_ neither happens before _y_ nor after _y_, we say that _x is concurrent with y_. This doesn't
mean that _x_ and _y_ are necessarily simultaneous, merely that we cannot assum anything about their
ordering. As we'll see in the next chapter, it's necessary to order certain events during the apps
execution to avoid problems that may arise when two Gs access the same var concurrently.

Here, we use a C to synchronize the two Gs:

```go
// gopl.io/ch8/netcat3
func main() {
    conn, err := net.Dial("tcp", "localhost:8000")
    if err != nil {
        log.Fatal(err)
    }
    done := make(chan struct{})
    go func() {
        io.Copy(os.Stdout, conn) // NOTE: ignoring errors
        log.Println("done")
        done <- struct{}{} // signal the main goroutine
    }()
    mustCopy(conn, os.Stdin)
    conn.Close()
    <-done // wait for background goroutine to finish
}
```

When the user closes the std io stream, `mustCopy` returns and the maun G calls `conn.Close()`,
closing both halves of the network conn. Closing the write half of the conn causes the server to see
and EOF condition. Closing the read half causes the background G's call to `io.Copy` to return a
"read from closed connection" error, which is why we've removed the error logging.

Before it returns, the bg G logs a message and then sends a val on the `done` C. The main G waits
until it has received this val before returning. As a result, the app always logs the "`done`"
message before exiting.

Messages sent over Cs have two important aspects. Each message has a value, but sometimes the fact 
of communication and the moment which it occurs are just as important. We call messages _events_ 
when we wish to stress this aspect. When the even carries no addit'l info, that is, its sole
purpose is synchronization, we'll emphasize this by using a C whose element type is `struct{}`,
though it's common to use a channel of `bool` or `int` for the same purpose since `done <- 1` is
shorter than `done <- struct{}{}`.

## Unbuffered Exercises

In `netcat3`, the interface val `conn` has the concrete type `*net.TCPConn`, for a TCP connection.
Modify the main G of `netcat3` to close only the write half of the connection so that the program
will continue to print the finall echoes from the `reverb1` server even after the std IO has been
closed.

## Pipelines

Cs can be used to connect Gs so that the output of one is the input to another. This is called a
_pipeline_. We can use 3 Gs with 2 Cs to make this happen:

```
fn Counter() -> fn Squarer() -> fn Printer()
```

`Counter()` generates the ints, sends them on a C, which is picked up by `Squarer()`, who then 
squares each value, and sends them on another C that is picked up by the `Printer()` fn.

```go
// gopl.io/ch8/pipeline1
func main() {
    naturals := make(chan int)
    squares := make(chan int)

    // Counter
    go func() {
        for x := 0; ; x++ {
            naturals <- x
        }
    }()

    // Squarer
    go func() {
        for {
            x := <-naturals
            squares <- x * x
        }
    }()

    // Printer (in main goroutine)
    for {
        fmt.Println(<-squares)
    }
}
```

Pipelines like this may be found in long-running server programs where Cs are used for lifelong
communication between Gs containing infinite loops. But what about sending only a finite number of
values?

If the sender knows that no further vals will ever be sent on a C, it is useful to communicate this
fact to the receiver Gs so they can stop waiting. 

```go
close(naturals)
```

After a C has been closed, any further _send_ operations on it will panic. After the C has been
_drained_ of all elements, all subsequent receive ops will proceed without blocking but will yield a
zero value. Closing the `naturals` C above would cause the `Squarer()` loop to spin at is receives a
never-ending stream of zero values, and to send these zeros to the `Printer()`.

There is no way to test directly if a C has been closed, but the receive op can also produce two
results: the element, plus a boolean value (called `ok`), which is `true` for a successful receive
and `false` for a receive on a closed and drained C. Using this, we can modify the `Squarer()` loop
to stop when the `naturals` C is drained and close the `squares` C.

```go
// Squarer
go func() {
    for {
        x, ok := <-naturals
        if !ok {
            break // channel was closed and drained
        }
        squares <- x * x
    }
    close(squares)
}()
```

Because the syntax above is clumsy and the pattern is common, Go let's us use a `range` to iterate
over Cs, too! This is much more convenient for receiving all the vals sent on a C and terminating
the loop after the last one.

In our revision below, we update it to use the `range` keyword. With fns, you may want to also do a
`defer` on the `close()`.

```go
// gopl.io/ch8/pipeline2
func main() {
    naturals := make(chan int)
    squares := make(chan int)

    // Counter
    go func() {
        for x := 0; x < 100; x++ {
            naturals <- x
        }
        close(naturals)
    }()

    // Squarer
    go func() {
      for x := range naturals {
            squares <- x * x
        }
        close(squares)
    }()

    // Printer (in main goroutine)
    for x := range squares {
        fmt.Println(x)
    }
}
```

You don't need to close every C when you are done with it, only when it's necessary to close a C when
it is important to tell the receiving Gs that all data has been sent. A C that the GC determines to
be unreachable will have its resources reclaimed, whether or not its closed. (for files, you _always_ need to call `Close()`)

Attempting to close a C that's been closed causes a panic, as does closing a `nil` C. Closing Cs has
another use as a broadcast mechanism, which is covered in 
[Chapter 67: Cancellation][cancellation-chapter].

## Unidirectional Channel Types

As apps grow, bigger fns get broken up into smaller pieces. Last example showed three Gs inside of
`main`. We'd want to divide into multiple fns:

```
func counter(out chan int)
func squarer(out, in chan int)
func printer(in chan int)
```

The `squarer` fn takes two params, and input and an output C. Both have the same type, but the
intended use is opposite: `in` gets pulled from, `out` is sent to. However, nothing about the code
restricts `squarer` from sending on `in`, or getting on `out`.

This is typical. When a C is a fn param, it is nearly always with the intent to be used exclusively
for sending or receiving. 

To document and restrict the potential misuse, we can use a _unidirectional_ C type that exposes only
onw or the other of the send and receive ops. `chan<- int` is a _send-only_ C, while `<-chan int` is
a _receive-only_ C. (The position of the `<-` relative to the `chan` keyword is a _mnemonic_.) Any
violation will now be detected at compile time.

Since the `close` op asserts that no more sends will occur on a C, only the _sending_ G is in a
position to call it, and you will get a compile-time error to attempt to close a receive-only C.

Here we go again, but with better C definitions:

```go
// gopl.io/ch8/pipeline3
func counter(out chan<- int) {
    defer close(out)
    for x := 0; x < 100; x++ {
        out <- x
    }
}
func squarer(out chan<- int, in <-chan int) {
    defer close(out)
    for v := range in {
        out <- v * v
    }
}

func printer(in <-chan int) {
    for v := range in {
        fmt.Println(v)
    }
}

func main() {
    naturals := make(chan int)
    squares := make(chan int)

    go counter(naturals)
    go squarer(squares, naturals)
    printer(squares)
}
```

The call `counter(naturals)` implicitly converts `naturals`, a val of `chan int`, to the type of the
param, `chan<- int`. The `printer(squares)` call does the same thing. Conversions from 
_bidirectional_ to _unidirectional_ C types are allowed. There is no, reverse, however. You cannot
extract or convert `chan int` from a `chan<- int`.

## Buffered Channels

A buffered C has a queue of elements. The max size is determined when it is created, by the capacity
arg to `make`. To create a buffered C with a capacity of three `string` values, we do:

```go
ch = make(chan string, 3)
```

A send op on a bC inserts an element at the back of the queue, and a receive op removes an element
from the front.  If the bC is full, the send op blocks its G until space is made available by another
G's receive. If the bC is empty, a receive op blocks until a value is sent by another G.

We can send up to three values on this C without blocking:

```go
ch <- "A"
ch <- "B"
ch <- "C"
```

Now, the C is full, and `ch <- "D"` would block. If we receive a value via `fmt.Println(<-ch)`, a
send or receive op could proceed without blocking. In this way, the C's buffer decouples the sending
and receiving Gs.

In the event you need to know a bC's capacity, simply call `cap(ch)`.

If you need to know the current length, use `len(ch)`. It's maybe not the best for use in 
concurrency but it can help with debugging.

After two more receive ops, the bC is empty, and a fourth would block.


```go
fmt.Println(<-ch)
fmt.Println(<-ch)
```

In this example, all send and receive ops were all done by the same G, but in real apps, they are
usually done by different Gs. Don't use bC's as queues withing a single G, however tempting it might 
be. C's are deeply tied to G scheduling and without another G receiving from the C, a sender (and
maybe the app) risks becoming blocked forever. If you just need a simple queue, use a slice.

An idea of _when_ to use a bC can be seen by the following code that simply does some mirror site
lookups and returns the first to respond (ie: the fastest).

```go
func mirroredQuery() string {
    responses := make(chan string, 3)
    go func() { responses <- request("asia.gopl.io") }()
    go func() { responses <- request("europe.gopl.io") }()
    go func() { responses <- request("americas.gopl.io") }()
    return <-responses // return the quickest response
}

func request(hostname string) (response string) {
  /* ... */
}
```

Had we used an _unbuffered_ C, the slower of the two Gs would have gotten stuck trying to send their
responses on a C from which no G will ever receive. This is a _goroutine leak_, and it would be a 
bug. Unlike garbage vars, leaked Gs are not automatically collected, so it is important to make sure
that Gs terminate themselves when they are no longer needed.

The choice between uC and bC, and a bC's capacity, may bother affect the correctness of an app. uC
gives strong sync guarantees because every send op is sync'd with its corresponding receive; with bCs
these are decoupled. Also, on a bC the upper bound is known, it's not unusual to create a bC of that
size and perform all the sends before the firt val is received. Failure to allocate proper capacity
would cause a deadlock.

C buffering may also affect performance. Imagine three cooks in a cake shop, each with a different
duty that needs to be done before passing it on to the next cook in an assembly line. In a kitchen
with little space, each cook that has finished a cake must wait for the next cook to become ready to
accept it; this is how communication over uCs work.

If there is a space for one cake between each cook, they can place a finished cake there and start on
the next; same as a bC with capacity of 1. So long as the cooks work at about the same rate, most of
the handovers proceed quickly, smoothing out transient differences in their rates. More space between
them (larger buffers) can smooth out bigger variations in their rates.

On the other hand, if an earlier stage of the assembly line is consistently faster than the following
stage, the buffer will tend to be full most of the time. However, if a later stage is faster, it is
generally going to have an empty buffer. Hence, a buffer provides no benefit here.

The assembly line metaphor is a useful one for Cs and Gs. If the second stage is more elaborate, a
single cook may not be able to keep up with the supply from the first or meet the demand from the 
third. To solve this, hiring another cook to help the second, performing the same task but working
independly. This is analogous to creating another G communicating over the same Cs.

Look at [the ch8 cake code][cake-shop] to see a simulation of this cake shop.

[🔙 Example: Concurrent Echo Server][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Looping in Parallel 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch061-example-concurrent-echo-server.md
[upcoming-chapter]: ch063-looping-in-parallel.md
[cancellation-chapter]: ch067-cancellation.md
[cake-shop]: https://github.com/adonovan/gopl.io/tree/master/ch8/cake

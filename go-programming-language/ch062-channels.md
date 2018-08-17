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






[🔙 Example: Concurrent Echo Server][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Looping in Parallel 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch061-example-concurrent-echo-server.md
[upcoming-chapter]: ch063-looping-in-parallel.md

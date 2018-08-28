[🔙 Example: Concurrent Web Crawler][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Example: Concurrent Directory Traversal 🔜][upcoming-chapter]

# Chapter 65. Multiplexing with `select`

The program below does the countdown for a rocket launch. `time.Tick` returns a C on which it sends
events periodically, like a metronome. Each value is a timestamp, but the delivery is the important
part.

```go
// gopl.io/ch8/countdown1
func main() {
    fmt.Println("Commencing countdown.")
    tick := time.Tick(1 * time.Second)
    for countdown := 10; countdown > 0; countdown-- {
        fmt.Println(countdown)
        <-tick
    }
    launch()
}
```

Now, let's add the ability to abort the launch sequence by pressing the return key during the
countdown. First, we start a G that tries to read a byte from the std IO, and if succesfful, sends
a val on a C called `abort`.

```go
// gopl.io/ch8/countdown2
abort := make(chan struct{})
go func() {
    os.Stdin.Read(make([]byte, 1)) // read a single byte
    abort <- struct{}{}
}()
```

Now each iteration of the countdown loop needs to wait for an event to arrive on one of the Cs: the
ticker C if it's all good, or an abort event if there is an anomaly. We can't just receive from
each C because whichever op we try first will block until completion. We need to _multiplex_ the
ops, and to do that, we use a _select_ statement:

```go
select {
case <-ch1:
    // ...
case x := <-ch2:
    // ...use x...
case ch3 <- y:
    // ...
default:
    // ...
}
```

The std form of a select statement is shown above. Its like a switch statement, with a number of
cases and an optional `default`. Each case specifies a _communication_ (a send/receive op on a C)
and an associated block of statements. A receive expression may appear on its own, or within a
short var declaration (second case shown). The second form lets you refer to the received val.

A `select` waits until a communication for some case is ready to proceed. It then performs that
communication and executes the case's associated statements; the other communications do not
happen. A `select` with no cases, `select{}` waits forever.

Back to the rocket launch! The `time.After` fn immediately returns a C, and starts a new G that
sends a single val on that C after the specified time. The below statement waits until either 10 
seconds have passed, or an abort event occurs.

```go
func main() {
    // ...create abort channel...

    fmt.Println("Commencing countdown.  Press return to abort.")
    select {
    case <-time.After(10 * time.Second):
        // Do nothing.
    case <-abort:
        fmt.Println("Launch aborted!")
        return
    }
    launch()
}
```

The example below is more subtle. The C `ch`, whose buffer size is 1, is alternatively empty then
full, so only one of the cases can proceed, either send when `i` is even, or receive when `i` is
odd. It always prints `0 2 4 6 8`.

```go
ch := make(chan int, 1)
for i := 0; i < 10; i++ {
    select {
    case x := <-ch:
        fmt.Println(x) // "0" "2" "4" "6" "8"
    case ch <- i:      // push onto the buffer
    }
}
```

If multiple cases are ready, `select` picks one at random, which ensures that every C has an equal
chance of being selected. Increasing the buffer size of the previous example makes it output
nondeterministic, because when the buffer is neither full nor empty, it basically does a coin toss.

Let's make our launch program print the countdown. The `select` statement below causes each
iteration of the loop to wait up to 1 second for an abort, but no longer.

```go
// gopl.io/ch8/countdown3
func main() {
    // ...create abort channel...

    fmt.Println("Commencing countdown.  Press return to abort.")
    tick := time.Tick(1 * time.Second)
    for countdown := 10; countdown > 0; countdown-- {
        fmt.Println(countdown)
        select {
        case <-tick:
            // Do nothing.
            case <-abort:
            fmt.Println("Launch aborted!")
            return
        }
    }
    launch()
}
```

The `time.Tick` fn behaves as if it creates a G and that calls `time.Sleep` in a loop, sending an
event each time it wakes up. When the countdown fn above returns, it stops receiving events from
`tick`, but the ticker G is still there, trying in vain to send on a C that no G is receiving from:
a _G leak_.

The `time.Tick` fn is convenient, but it's appropriate only when the ticks are needed throughout
the lifetime of the app, otherwise, we should follow this pattern:

```go
ticker := time.NewTicker(1 * time.Second)

<-ticker.C // receive from the ticker's channel

ticker.Stop() // cause the ticker's goroutine to terminate
```

Sometimes we want to try to send or receive on a C but avoid blocking if the C is not ready -- a
_non-blocking_ communication. A `select` statement can do that, too. A `select` may have a 
`default`, which specifies what to do when no other case can proceed immediately.

The `select` belowe receives a value from `abort` C if there is one, else it does nothing. This
is a non-blocking receive op, and doing it repeatedly is called _polling_ a C.

```go
select {
case <-abort:
    fmt.Printf("Launch aborted!\n")
    return
default:
    // do nothing
}
```

The zero val for a C is `nil`. Perhaps surprising, nil Cs are sometimes useful. Because send and
receiev ops on a nil C block forever, a case in a `select` statement whose C is nil is never
selected. This lets us use `nil` to enable or disable cases that correspond to features like
handling timeouts or cancellation, responding to other input events, or emitting output.

## Exercises

* Add a timeout to the echo server from 8.3 so it disconnects any client that shouts nothing after
10 seconds.

[🔙 Example: Concurrent Web Crawler][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Example: Concurrent Directory Traversal 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch064-example-concurrent-web-crawler.md
[upcoming-chapter]: ch066-example-concurrent-directory-traversal.md

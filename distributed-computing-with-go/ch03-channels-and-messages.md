[🔙 Understanding Goroutines][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[The RESTful Web 🔜][upcoming-chapter]

# Chapter 3. Channels and Messages

In reality, goroutines are more capable than what was shown in the previous chapter, and channels
will help us unlock that potential.

## Controlling Parallelism

We know that spawned G will start executing as soon as possible and in a simultaneous fashion, but
there is an inherent risk when they need to work on a common source that has a lower limit on the
number of simultaneous tasks it can handle. This might cause the common source to significantly
slow down or, potentially, fail.

This is not a new problem, and there are many ways to handle it.

Let's simulate the problem of a burdened common source, and then proceed to solve it.

**Problem:** Imagine a cashier who has to process orders, but has a limit to process only 10
orders in a day.

```go
// cashier.go
package main

import (
  "fmt"
  "sync"
)

func main() {
  var wg sync.WaitGroup
  // ordersProcessed & cashier are declared in main function
  // so that cashier has access to shared state variable 'ordersProcessed'.
  // If we were to declare the variable inside the 'cashier' function,
  // then it's value would be set to zero with every function call.
  ordersProcessed := 0
  cashier := func(orderNum int) {
    if ordersProcessed < 10 {
      // Cashier is ready to serve!
      fmt.Println("Processing order", orderNum)
      ordersProcessed++
    } else {
      // Cashier has reached the max capacity of processing orders.
      fmt.Println("I am tired! I want to take rest!", orderNum)
    }
    wg.Done()
  }

  for i := 0; i < 30; i++ {
    // Note that instead of wg.Add(60), we are instead adding 1
    // per each loop iteration. Both are valid ways to add to WaitGroup as long as we can ensure the right number of calls.
    wg.Add(1)
    go func(orderNum int) {
      // Making an order
      cashier(orderNum)
    }(i)

  }
  wg.Wait()
}
```

Possible output is:

```
Processing order 1
Processing order 15
Processing order 3
Processing order 4
Processing order 5
Processing order 6
Processing order 0
Processing order 29
Processing order 16
Processing order 17
I am tired! I want to take rest! 18
I am tired! I want to take rest! 19
I am tired! I want to take rest! 20
Processing order 11
I am tired! I want to take rest! 21
I am tired! I want to take rest! 22
I am tired! I want to take rest! 23
I am tired! I want to take rest! 8
I am tired! I want to take rest! 26
I am tired! I want to take rest! 24
I am tired! I want to take rest! 25
Processing order 7
I am tired! I want to take rest! 9
I am tired! I want to take rest! 10
I am tired! I want to take rest! 27
I am tired! I want to take rest! 28
I am tired! I want to take rest! 14
I am tired! I want to take rest! 13
I am tired! I want to take rest! 12
Processing order 2
```

The preceding output shows a cashier who was overwhelmed after taking 10 orders, but running the
program multiple times, you are likely to get different outputs. There is actually the potential
for all 30 orders to be processed in one of the runs.

Welcome to **race conditions**. A data race (or race condition) occurs when multiple actors, like
goroutines, are trying to access and modify a common shared state, and this results in incorrect
reads and writes by the Gs.

We have two potential solutions.

We can **increase the limit for processing orders**. This is only feasible to a certain extent, 
because it would eventually start degrading the system, or in case of the cashier, work will 
neither be efficient nor 100% accurate.

We can also **increase the number of cashiers**. This is the saner and safer way to start 
processing orders more consecutively while not channging the limit.

We then need to decide how to approach the cashier increase, as there are two approaches:

* Distributed work without channels.
* Distributed work with channels.

### Distributed Work Without Channels

In order to distribute the work equally among the cashiers, we need to know the amount of orders
we will get beforehand and ensure that the work each cashier receives is within their limit. Not
the most practical, as it would fail in a real-world scenario, since we'd need to keep track of
how many orders each cashier has processed and divert the remaining orders to the others.

Regardless, let's take the time to better understand the problem of uncontrolled parallelism and
try to solve it. 

This code presents a naive manner, which is a good start for us:

```go
// wochan.go

package main

import (
  "fmt"
  "sync"
)

func createCashier(cashierID int, wg *sync.WaitGroup) func(int) {
  ordersProcessed := 0
  return func(orderNum int) {
    if ordersProcessed < 10 {
      // Cashier is ready to serve!
      fmt.Println("Cashier", cashierID, "Processing order", orderNum, "Orders Processed", ordersProcessed)
      ordersProcessed++
    } else {
      // Cashier has reached the max capacity of processing orders.
      fmt.Println("Cashier ", cashierID, "I am tired! I want to take rest!", orderNum)
    }
    wg.Done()
  }
}

func main() {
  cashierIndex := 0
  var wg sync.WaitGroup

  // cashier{1,2,3}
  cashiers := []func(int){}
  for i := 1; i <= 3; i++ {
    cashiers = append(cashiers, createCashier(i, &wg))
  }

  for i := 0; i < 30; i++ {
    wg.Add(1)

    cashierIndex = cashierIndex % 3

    func(cashier func(int), i int) {
      // Making an order
      go cashier(i)
    }(cashiers[cashierIndex], i)

    cashierIndex++
  }
  wg.Wait()
}
```

Here's one possible output:

```
Cashier 3 Processing order 2 Orders Processed 0
Cashier 2 Processing order 1 Orders Processed 0
Cashier 2 Processing order 4 Orders Processed 1
Cashier 1 Processing order 3 Orders Processed 0
Cashier 3 Processing order 5 Orders Processed 1
Cashier 3 Processing order 11 Orders Processed 2
Cashier 2 Processing order 7 Orders Processed 2
Cashier 3 Processing order 8 Orders Processed 3
Cashier 1 Processing order 9 Orders Processed 1
Cashier 2 Processing order 10 Orders Processed 3
Cashier 2 Processing order 22 Orders Processed 4
Cashier 1 Processing order 6 Orders Processed 0
Cashier 3 Processing order 29 Orders Processed 4
Cashier 3 Processing order 17 Orders Processed 1
Cashier 1 Processing order 0 Orders Processed 0
Cashier 2 Processing order 19 Orders Processed 5
Cashier 2 Processing order 25 Orders Processed 5
Cashier 3 Processing order 14 Orders Processed 6
Cashier 3 Processing order 23 Orders Processed 6
Cashier 2 Processing order 13 Orders Processed 5
Cashier 2 Processing order 28 Orders Processed 7
Cashier 1 Processing order 18 Orders Processed 2
Cashier 1 Processing order 21 Orders Processed 4
Cashier 3 Processing order 20 Orders Processed 4
Cashier 1 Processing order 15 Orders Processed 4
Cashier 3 Processing order 26 Orders Processed 6
Cashier 1 Processing order 27 Orders Processed 4
Cashier 1 Processing order 24 Orders Processed 4
Cashier 2 Processing order 16 Orders Processed 7
Cashier 1 Processing order 12 Orders Processed 2
```

We split the 30 orders between 3 cashiers and all of them were successfully processed without
any complaints of tiredness. This code too a lot of work on our end, and we even had to create
a function generator to create cashiers, as well as keep track of which cashier to use, and so on.
_And the worst part is that the preceding code isn't even correct!_ We are spawning multiple
goroutines that are working on variables with a shared state, causing race conditions.

Let's look at how we can detect that race condition:

* In the `createCashier` function, change the `fmt.Println` to `fmt.Println(cashierID, "->", ordersProcessed)`
  * Possible output:
    ```
    3 -> 0
    3 -> 1
    1 -> 0
    ...
    2 -> 3
    3 -> 1  # Cashier 3 sees ordersProcessed as 1 but three lines above, Cashier 3     
    was at ordersProcessed == 4!
    3 -> 5
    1 -> 4
    1 -> 4 # Cashier 1 sees ordersProcessed == 4 twice.
    2 -> 4
    2 -> 4 # Cashier 2 sees ordersProcessed == 4 twice.
    ...
    ```
* The above point proves that the code is not correct, since we had to guess the possible issue in
the code and then verify it. Go actually provides us with tools to detect data races so that we
don't have to worry about such issues. All we have to do to detect a data race is to test, run,
build, or install the package (or file) with the `-race` flag.
```
$ go run -race wochan.go
Cashier  1 Processing order 0
Cashier  2 Processing order 1
==================
WARNING: DATA RACE
Cashier  3 Processing order 2
Read at 0x00c4200721a0 by goroutine 10:
main.createCashier.func1()
wochan.go:11 +0x73

Previous write at 0x00c4200721a0 by goroutine 7:
main.createCashier.func1()
wochan.go:14 +0x2a7

Goroutine 10 (running) created at:
main.main.func1()
wochan.go:40 +0x4a
main.main()
wochan.go:41 +0x26e

Goroutine 7 (finished) created at:
main.main.func1()
wochan.go:40 +0x4a
main.main()
wochan.go:41 +0x26e
==================
Cashier  2 Processing order 4
Cashier  3 Processing order 5
==================
WARNING: DATA RACE
Read at 0x00c420072168 by goroutine 9:
main.createCashier.func1()
wochan.go:11 +0x73

Previous write at 0x00c420072168 by goroutine 6:
main.createCashier.func1()
wochan.go:14 +0x2a7

Goroutine 9 (running) created at:
main.main.func1()
wochan.go:40 +0x4a
main.main()
wochan.go:41 +0x26e

Goroutine 6 (finished) created at:
main.main.func1()
wochan.go:40 +0x4a
main.main()
wochan.go:41 +0x26e
==================
Cashier  1 Processing order 3
Cashier  1 Processing order 6
Cashier  2 Processing order 7
Cashier  3 Processing order 8
...
Found 2 data race(s)
exit status 66
```

As can be seen, the `race` flag helped us to detect the data race.

Does this mean that we cannot distribute our tasks when we have shared state? Of course we can!
However, we need to use mechanisms provided by Go for this purpose:

* Mutexes, semaphores, and locks.
* Channels.

Mutex is a mutual exclusion lock that provides us with a sync mechanism to allow only one G to
access a particular piece of code or shared state at any given point in time. 

Go recommends using the right construct for the job, and while mutexes have uses, channels will
end up being the goto construct for us.

### Distributed Work With Channels

We are certain about three things now:

1. We want to distribute our orders among the cashiers correctly.
1. We want to ensure that the correct number of orders are process by each cashier.
1. We want to use channels to solve this problem.

So... what's a channel, and how do we use them?

#### What Is a Channel?

A channel is a communication mechanism that allows us to pass data between Gs. It is an in-built
data type in Go. Data can be passed using one of the primitive data types or we can create
our own complex data type using structs.

Here's a simple channel demo:

```go
// simchan.go 
package main 
 
import "fmt" 
 
// helloChan waits on a channel until it gets some data and then prints the value. 
func helloChan(ch <- chan string) { 
    val := <- ch 
    fmt.Println("Hello, ", val) 
} 
 
func main() { 
    // Creating a channel 
    ch := make(chan string) 
 
    // A Goroutine that receives data from a channel 
    go helloChan(ch) 
 
    // Sending data to a channel. 
    ch <- "Bob" 
}
```

If we run the preceding code, it should print:

```
Hello, Bob
```

The basic pattern for using channels can be explained by the following steps:

1. Create the channel to accept the data to be processed.
1. Launch the Gs that are waiting on the channel for data.
1. Use either the `main` function or other Gs to pass data into the channel.
1. The Gs listening on the channel can accept the data and process them.

The advantage of using channels is that multiple Gs can wait on the same channel and execute tasks
concurrently.

#### Solving the Cashier Problem with Goroutines

Before we try to solve the problem, let's think about what we want to achieve:

1. Create a channel `orderChannel` that accepts all orders.
1. Launch the required number of `cashier` Gs that accept limited numbers of orders from
   `orderChannel`.
1. Start putting all orders into `orderChannel`.

Here's one possible solution using the above steps:

```go
package main

import (
  "fmt"
  "sync"
)

func cashier(cashierID int, orderChannel <-chan int, wg *sync.WaitGroup) {
  // Process orders upto limit.
  for ordersProcessed := 0; ordersProcessed < 10; ordersProcessed++ {
    // Retrieve order from orderChannel
    orderNum := <-orderChannel

    // Cashier is ready to serve!
    fmt.Println("Cashier", cashierID, "Processing order", orderNum, "Orders Processed", ordersProcessed)
    wg.Done()
  }
}

func main() {
  var wg sync.WaitGroup
  wg.Add(30)
  ordersChannel := make(chan int)

  for i := 0; i < 3; i++ {
    // Start the three cashiers
    func(i int) {
      go cashier(i, ordersChannel, &wg)
    }(i)
  }

  // Start adding orders to be processed.
  for i := 0; i < 30; i++ {
    ordersChannel <- i
  }
  wg.Wait()
}
```

Running the code with the `-race` flag shows us that the code ran without any data races:

```
$ go run -race wichan.go 
Cashier  2 Processing order 2 Orders Processed 0
Cashier  2 Processing order 3 Orders Processed 1
Cashier  0 Processing order 0 Orders Processed 0
Cashier  1 Processing order 1 Orders Processed 0
...
Cashier  0 Processing order 27 Orders Processed 9
```

The code is quite straightforward, easy to parallelize, and works well without causing data races.

### Channels and Data Communication

Go is a sttically type language, and this means that a given channel can only send or receive data
of a single type. In Go's terminology, this is known as a channel's **element type**. A Go channel
will accept any valid Go data type, including functions.

Here's an example of a simple program that accepts and calls on functions:

```go
// elems.go
package main

import "fmt"

func main() {
  // Let's create three simple functions that take an int argument
  fcn1 := func(i int) {
    fmt.Println("fcn1", i)
  }
  fcn2 := func(i int) {
    fmt.Println("fcn2", i*2)
  }
  fcn3 := func(i int) {
    fmt.Println("fcn3", i*3)
  }

  ch := make(chan func(int)) // Channel that sends & receives functions that take an int argument
  done := make(chan bool)    // A Channel whose element type is a boolean value.

  // Launch a goroutine to work with the channels ch & done.
  go func() {
    // We accept all incoming functions on Channel ch and call the functions with value 10.
    for fcn := range ch {
      fcn(10)
    }
    // Once the loop terminates, we print Exiting and send true to done Channel.
    fmt.Println("Exiting")
    done <- true
  }()

  // Sending functions to channel ch
  ch <- fcn1
  ch <- fcn2
  ch <- fcn3

  // Close the channel once we are done sending it data.
  close(ch)

  // Wait on the launched goroutine to end.
  <-done
}
```

The output is pretty straightforward:

```
fcn1 10
fcn2 20
fcn3 30
Exiting
```

In the preceding code, we say that the channel `ch` has the element type of `func(int)` and that
the channel `done` has the element type of `bool`. That's the gist of it, though there is more to
it.

#### Messages and Events

So far the term _data_ has referred to the values being sent and received from a channel. Simple,
but not exactly correct. Go uses the terms **messages** and **events** for data being communicated
over channels. In terms of implementation, they are identical, but the terms are used to help us
understand the _type_ of data being sent.

* **Messages** are generally values we want the G to process and act on, if required.
* **Events** are used to signify that a certain _event_ has occurred. The value itself may not be
near as important as the act of receiving a value. Even though we use the term _event_, they are
still a type of _message_.

In the previous code, values sent to `ch` are messages, while the value sent to `done` is an 
event. An important note is that the element typs of event channels to to be `struct{}{}`, `bool`,
or `int`.

So that's channel element types, messages, and events. Now for the different types of channels.

### Types of Channels

We get **Unbuffered**, **Buffered**, and **Unidirectional** (send-only and receive-only type
channels.

#### The Unbuffered Channel

The basic channel type, it's very straightforward. We send data into the channel and we receive
data at the other end. _Any G operating on an unbuffered channel will be blocked until both the
sender and the receiver Gs are available._ Consider the following:

```go
ch := make(chan int) 
go func() {ch <- 100}     // Send 100 into channel.                
                          // Channel: send100          
go func() {val := <- ch}  // Goroutine waiting on channel.        
                          // Channel: recv1         
go func() {val := <- ch}  // Another goroutine waiting on channel.
                          // Channel: recv2
```

We have a channel `ch` of element type `int`. We start three Gs; one sends a message of `100` onto
the channel (`send100`) and the other two Gs (`recv1` and `recv2`) wait on the channel. `send100`
is blocked until either of `recv1` or `recv2` starts listening on the channel to receive the
message. If we assume that `recv2` received the message sent on the channel by `send100`, then
`recv1` will be waiting until another message is sent on the channel. If the preceding four lines
are the only communcation on the channel, then `recv1` will idle until the program ends and will
be terminated by the Go runtime.

#### The Buffered Channel

Consider the case where we are able to send more messages into a channel than the Gs receiving
them can handle. Using the former _unbuffered_ channels, it would slow down the program a lot
because we will have to wait for each message to be processed before we can put in another 
message. It'd be great if the channel could store these extra messages or "buffer" them. Well,
that's what a buffered channel does. It maintains a queue of messages that a G will consume at its
own pace. However, even these have a limited capacity, so we need to define the capacity of the
queue at the time of channel creation.

Syntax-wise, we can use a buffered channel just like an unbuffered channel. The behavior is:

* **If a buffered channel is empty:** receiving messages on the channel is blocked until a message
is sent across the channel.
* **If a buffered channel is full:** sending messages on the channel is blocked until at least one
message is received from the channel, thus freeing up space for the new message to be put on the
queue.
* **If a buffered channel is partially filled up:** either sending or receiving on a channel is
unblocked and the communication is instantaneous.

![buffered-communication][buffered-communication]

#### The Unidirectional Buffer

Messages can be sent and received from a channel, but when Gs use channels for communcation, they
are generally for a single purpose: either to send or receive from a channel. Go allows us to
tell it whether a channel is being used by a G for sending or receiving messages. This is
accomplished with the help of unidirectional channels. Once the channel has been identified as
such, we cannot perform the other operation on them. So a send-only channel cannot be used to
receive messages, and vice-versa. Doing so will cause a compile-time error.

Here's a simple example of unidrectional channels being used correctly:

```go
// unichans.go
package main

import (
  "fmt"
  "sync"
)

// it takes in _from_ a channel
func recv(ch <-chan int, wg *sync.WaitGroup) {
  fmt.Println("Receiving", <-ch)
  wg.Done()
}

// it sends in _to_ a channel
func send(ch chan<- int, wg *sync.WaitGroup) {
  fmt.Println("Sending...")
  ch <- 100
  fmt.Println("Sent")
  wg.Done()
}

func main() {
  var wg sync.WaitGroup
  wg.Add(2)

  ch := make(chan int)
  go recv(ch, &wg)
  go send(ch, &wg)

  wg.Wait()
}
```

The expected output is:

```
Sending...
Receiving 100
Sent
```

If you try and send over a receiving channel, you get a compiler error:

```go
// unichans2.go 
// ... 
// Changed function 
func recv(ch <-chan int, wg *sync.WaitGroup) { 
    fmt.Println("Receiving", <-ch) 
    fmt.Println("Trying to send") // signalling that we are going to send over channel. 
    ch <- 13                      // Sending over channel 
    wg.Done() 
}
```

You'll see something akin to the following:

```
prog.go:18:8: invalid operation: ch <- 13 (send to receive-only type <-chan int)
```

So, how would the program behave if we used a buffered channel? Since there will be no blocking on
an unfilled channel, the `send` G sends a message onto the channel and then continues executing.
The `recv` G reads from the channel when it starts executing and then prints it:

```go
// buffchan.go
package main

import (
  "fmt"
  "sync"
)

func recv(ch <-chan int, wg *sync.WaitGroup) {
  fmt.Println("Receiving", <-ch)
  wg.Done()
}

func send(ch chan<- int, wg *sync.WaitGroup) {
  fmt.Println("Sending...")
  ch <- 100
  fmt.Println("Sent")
  wg.Done()
}

func main() {
  var wg sync.WaitGroup
  wg.Add(2)

  // Using a buffered channel.
  ch := make(chan int, 10)
  go recv(ch, &wg)
  go send(ch, &wg)

  wg.Wait()
}
```

The output would be as follows:

```
Sending...
Sent
Receiving 100
```

### Closing Channels

In the previous sections, we've looked at three types of channels and how to create them. Let's
look at how to close the channels and how it may affect sending and receiving on these channels.
We close a channel when we no longer want to send any messages on it. How it behaves after being
closed is different for each type of channel.

* **Unbuffered closed channel:** sending messages will cause panic and receiving on it will yield
an immediate zero value of the channel's element type.
* **Buffered closed channel:** sending messages will cause panic but receiving on it will first
yield all the values in its queue. Once the queue has been exhausted, the channel will start
yielding zero values of the channel's element type.

Let's see it in action:

```go
// closed.go
package main

import "fmt"

type msg struct {
  ID    int
  value string
}

func handleIntChan(intChan <-chan int, done chan<- int) {
  // Even though there are only 4 elements being sent via channel, we retrieve 6 values.
  for i := 0; i < 6; i++ {
    fmt.Println(<-intChan)
  }
  done <- 0
}

func handleMsgChan(msgChan <-chan msg, done chan<- int) {
  // We retrieve 6 values of element type struct 'msg'.
  // Given that there are only 4 values in the buffered channel,
  // the rest should be zero value of struct 'msg'.
  for i := 0; i < 6; i++ {
    fmt.Println(fmt.Sprintf("%#v", <-msgChan))
  }
  done <- 0
}

func main() {
  intChan := make(chan int)
  done := make(chan int)

  go func() {
    intChan <- 9
    intChan <- 2
    intChan <- 3
    intChan <- 7
    close(intChan)
  }()
  go handleIntChan(intChan, done)

  msgChan := make(chan msg, 5)
  go func() {
    for i := 1; i < 5; i++ {
      msgChan <- msg{
        ID:    i,
        value: fmt.Sprintf("VALUE-%v", i),
      }
    }
    close(msgChan)
  }()
  go handleMsgChan(msgChan, done)

  // We wait on the two channel handler goroutines to complete.
  <-done
  <-done

  // Since intChan is closed, this will cause a panic to occur.
  intChan <- 100
}
```

Here's what you can expect for the possible output:

```
9
2
3
7
0
0
main.msg{ID:1, value:"VALUE-1"}
main.msg{ID:2, value:"VALUE-2"}
main.msg{ID:3, value:"VALUE-3"}
main.msg{ID:4, value:"VALUE-4"}
main.msg{ID:0, value:""}
main.msg{ID:0, value:""}
panic: send on closed channel

goroutine 1 [running]:
main.main()
  /Users/jmills/go/src/distributed-computing/ch03/cashier/channels-being-closed-demo.go:59 +0x164
exit status 2
```

Finally, here are some more useful points about closing channels and closed channels:

* It is not possible to determine if a channel has been closed, the best we can do is check if we
were able to successfully receive a message from a channel. We would use the variant syntax of
`msg := <- ch`, which is `msg, ok := <-ch`. The second param tells us if the retrieval was a
success. If the channel is closed, then `ok` will be false.
* `msg, ok := <-ch` is a common pattern when iterating over channels. As a result, Go allows us
to range over a channel, and when the channel closes, the `range` loop ends.
* Closing a closed channel, nil channel, or a receive-only channel will cause panic. Only a
bidrectional channel or send-only channel can be closed.
* It is not mandatory to close a channel and is irrelevant for the **garbage collector (GC)**. If
the GC determines that a channel is unreachable, the channel will be GC'd.

### Multiplexing Channels

Multiplexing describes the methodology where we use a single resource to act upon multiple signals
or actions. This method is used extensively in telecom and computer networks. We might find
ourselves in a situation where we have multiple types of tasks that we want to execute. However,
then can only be executed in mutual exclusing, or they need to work on a shared resource. For
this, we make use of a pattern in Go known as **channels multiplexing**. Before we dig into it,
let's see what happens if we try to implement it on our own.

So, let's say we have a set of channels and we want to act on them as soon as data is sent over a
channel. Here's a naive approach on how we want to do this:

```go
// naiveMultiplexing.go
package main

import "fmt"

func main() {
  channels := [5](chan int){
    make(chan int),
    make(chan int),
    make(chan int),
    make(chan int),
    make(chan int),
  }

  go func() {
    // Starting to wait on channels
    for _, chX := range channels {
      fmt.Println("Receiving from", <-chX)
    }
  }()

  for i := 1; i < 6; i++ {
    fmt.Println("Sending on channel:", i)
    channels[i] <- 1
  }
}
```

Run the above and you'll get something like:

```
Sending on channel: 1
fatal error: all goroutines are asleep - deadlock!

goroutine 1 [chan send]:
main.main()
  /Users/jmills/go/src/distributed-computing/ch03/cashier/naive-multiplexing.go:24 +0x1af

goroutine 5 [chan receive]:
main.main.func1(0xc42001e0c0, 0xc42001e120, 0xc42001e180, 0xc42001e1e0, 0xc42001e240)
  /Users/jmills/go/src/distributed-computing/ch03/cashier/naive-multiplexing.go:18 +0x89
created by main.main
  /Users/jmills/go/src/distributed-computing/ch03/cashier/naive-multiplexing.go:15 +0x18b
exit status 2
```

In the loop inside the G, the first channel is never waited upon and this causes the deadlock.
Multiplexing helps us wait on multiple channels without blocking any of them while acting on a
message once it is available on a channel.

Some important things to remember when multiplexing on channels:

**Syntax:**

```go
select {
case <-ch1:
  // Statements to execute if ch1 receives a message
case val := <-ch2:
  // Save message received from ch2 into a variable and execute statements for ch2
}
```

* It is possible that, byt the time `select` is excuted, more than one case is ready with a
message. In this case, `select` will not execute all of the cases, but will pick one at random,
execute it, and then exit the `select` statement.
* However, the preceding point may be limited if we want to react on messages being sent to all
the channels in `select` cases. Then we can put the `select` statement inside a `for` loop and it
will ensire that all messages will be handled.
* Even though the `for` loop will handle messages sent on all channels, the loop will still be
blocked until a message is available on it. There may be scenarios where we don't want to block
the loop iteration and instead do a "default" action. This can be achieved using `default` as the
case in the `select` statement.

**Updated syntax based on points made:**

```go
for {
  select {
  case <-ch1:
  // Statements to execute if ch1 receives a message
  case val := <-ch2:
  // Save message received from ch2 into a variable and execute statements for ch2
  default:
    // Statements to execute if none of the channels has yet received a message.
  }
}
```

💡 Tip: if you are using buffered channels, the order in which the messages are received is not
guaranteed.

Here's the proper way to multiplex on all the required channels without being blocked on any and
continuing to work on all the messages being sent:

```go
// multiplexing.go
package main

import (
  "fmt"
)

func main() {
  ch1 := make(chan int)
  ch2 := make(chan string)
  ch3 := make(chan int, 3)
  done := make(chan bool)
  completed := make(chan bool)

  ch3 <- 1
  ch3 <- 2
  ch3 <- 3
  go func() {
    for {
      select {
      case <-ch1:
        fmt.Println("Received data from ch1")
      case val := <-ch2:
        fmt.Println(val)
      case c := <-ch3:
        fmt.Println(c)
      case <-done:
        fmt.Println("exiting...")
        completed <- true
        return
      }
    }
  }()

  ch1 <- 100
  ch2 <- "ch2 msg"
  // Uncomment us to avoid leaking the 'select' goroutine!
  //close(done)
  //<-completed
}
```

Here's the output you'll receive:

```
1
2
Received data from ch1
3
```

You'll notice that there is a flaw: it leaks the G's handling, `select`. The comment mentions it, 
but let's undertstand why. This happens when we have a G that is running but we cannot directly
readch it. Even if a G's reference isn't store, the GC wont grab it. Therefore, we need a
mechanism to stop and return from such Gs. We can achieve our desires by creating a channel
specifically for returning from the G.

Let's uncomment the lines at the bottom of `main` and run it again:

```
1
2
3
Received data from ch1
ch2 msg
```

[🔙 Understanding Goroutines][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[The RESTful Web 🔜][upcoming-chapter]

[readme]:                  README.md
[previous-chapter]:        ch02-understanding-goroutines.md
[upcoming-chapter]:        ch04-the-restful-web.md
[buffered-communication]:  images/ch03-buffered-channel-communication.png

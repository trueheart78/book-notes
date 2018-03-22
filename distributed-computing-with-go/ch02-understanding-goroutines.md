[🔙 Development Environment for Go][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Channels and Messages 🔜][upcoming-chapter]

# Chapter 2. Understanding Goroutines

Conceptually, coroutines and channels have evolved over time and have been implemented differently
in many different programming languages.

## Concurrency and Parallelism

Standard definitions can be found on the [Concurrency is not Parallelism][go-blog] Go blog post,
or [watch the talk][go-youtube]:

* **Concurrency**: _Concurrency is about dealing with lots of things at once._
* **Parallelism**: _Parallelism is about doing lots of things at once._

![concurrency-vs-parallelism][concurrency-vs-parallelism]

### Concurrency

Let's think on concurrency using daily tasks and how they may get performed.

Here, you've got six tasks for the day:

1. Make hotel reservation
1. Book flight tickets
1. Order a dress
1. Pay credit card bills
1. Write an email
1. Listen to an audiobook

The order does not matter, and some of the longer tasks could take more than a single sitting.
Here's one possible completion manner:

1. Order a dress.
1. Write one-third of the email.
1. Make hotel reservation.
1. Listen to 10 minutes of audiobook.
1. Pay credit card bills.
1. Write another one-third of the email.
1. Book flight tickets.
1. Listen to another 20 minutes of audiobook.
1. Complete writing the email.
1. Continue listening to audiobook until you fall asleep.

That's **concurrency** in practice.

The idea here is to write a program to do all the preceding steps concurrently. however, let's
start with a sequential app and adapt it to work with coroutines.

The app will be built in three stages:

1. Serial task execution
1. Serial task execution with goroutines
1. Concurrent task execution

#### Code Overview

The code will consiste of a set of functions that pront out their assigned tasks as completed.
For the multistage parts, they'll have a function for each instance.

#### Serial Task Execution

```go
package main

import "fmt"

func makeHotelReservation() {
  fmt.Println("Done making hotel reservation.")
}
func bookFlightTickets() {
  fmt.Println("Done booking flight tickets.")
}
func orderADress() {
  fmt.Println("Done ordering a dress.")
}
func payCreditCardBills() {
  fmt.Println("Done paying credit card bills.")
}

func writeEmail() {
  fmt.Println("Wrote a 1/3rd of the email.")
  continueWritingEmail1()
}

func continueWritingEmail1() {
  fmt.Println("Wrote a 2/3rds of the email.")
  continueWritingEmail2()
}

func continueWritingEmail2() {
  fmt.Println("Done writing the email.")
}

func listenToAudioBook() {
  fmt.Println("Listened to 1/2 of the audio book.")
  continueListeningToAudioBook()
}

func continueListeningToAudioBook() {
  fmt.Println("Done listening to audio book.")
}

var listOfTasks = []func() {
  makeHotelReservation, bookFlightTickets, orderADress,
  payCreditCardBills, writeEmail, listenToAudioBook,
}

func main() {
  for _, task := range listOfTasks {
    task()
  }
}
```

Each of the main tasks are executed in sequential order, and the code will output the following:

```
Done making hotel reservation.
Done booking flight tickets.
Done ordering a dress.
Done paying credit card bills.
Wrote a 1/3rd of the email.
Wrote a 2/3rds of the email.
Done writing the email.
Listened to 1/2 of the audio book.
Done listening to audio book.
```

#### Serial Task Execution with Goroutines

Let's make the _writingEmail()_ and _listenToAudioBook()_ methods concurrent.

```go
func writeEmail() {
  fmt.Println("Wrote a 1/3rd of the email.")
  go continueWritingEmail1() // See new 'go' keyword
}

func continueWritingEmail1() {
  fmt.Println("Wrote a 2/3rds of the email.")
  go continueWritingEmail2() // See new 'go' keyword
}

func continueWritingEmail2() {
  fmt.Println("Done writing the email.")
}

func listenToAudioBook() {
  fmt.Println("Listened to 1/2 of the audio book.")
  go continueListeningToAudioBook() // See new 'go' keyword
}

func continueListeningToAudioBook() {
  fmt.Println("Done listening to audio book.")
}
```

Unfortunately, it's not that simple, as the output will show you there are missing tasks.

```
Done making hotel reservation.
Done booking flight tickets.
Done ordering a dress.
Done paying credit card bills.
Wrote a 1/3rd of the email.
Listened to 1/2 of the audio book.
```

❓ **Why:** Goroutines are not waited upon, and the code in the `main` function continues
executing and when the end of `main` hits, the program ends. We can use _channels_ for this,
but since the next chapter is dedicated to those, we're going to use a `WaitGroup`.

`WaitGroup` overview:

* Use `WaitGroup.add(int)` to keep count of how many goroutines we will be running as part of our
logic.
* Use `WaitGroup.Done()` to signal that a goroutine is done with its task.
* Use `WaitGroup.Wait()` to wait until all goroutines are done.
* Pass `WaitGroup` instance to the goroutines so they can call the `Done()` method.

So this will require code modification.

```go
package main

import (
  "fmt"
  "sync"
)

func makeHotelReservation(wg *sync.WaitGroup) {
  fmt.Println("Done making hotel reservation.")
  wg.Done()
}
func bookFlightTickets(wg *sync.WaitGroup) {
  fmt.Println("Done booking flight tickets.")
  wg.Done()
}
func orderADress(wg *sync.WaitGroup) {
  fmt.Println("Done ordering a dress.")
  wg.Done()
}
func payCreditCardBills(wg *sync.WaitGroup) {
  fmt.Println("Done paying credit card bills.")
  wg.Done()
}

func writeEmail(wg *sync.WaitGroup) {
  fmt.Println("Wrote a 1/3rd of the email.")
  go continueWritingEmail1(wg)
}

func continueWritingEmail1(wg *sync.WaitGroup) {
  fmt.Println("Wrote a 2/3rds of the email.")
  go continueWritingEmail2(wg)
}

func continueWritingEmail2(wg *sync.WaitGroup) {
  fmt.Println("Done writing the email.")
  wg.Done()
}

func listenToAudioBook(wg *sync.WaitGroup) {
  fmt.Println("Listened to 1/2 of the audio book.")
  go continueListeningToAudioBook(wg)
}

func continueListeningToAudioBook(wg *sync.WaitGroup) {
  fmt.Println("Done listening to audio book.")
  wg.Done()
}

var listOfTasks = []func(*sync.WaitGroup){
  makeHotelReservation, bookFlightTickets, orderADress,
  payCreditCardBills, writeEmail, listenToAudioBook,
}

func main() {
  var waitGroup sync.WaitGroup    // new WaitGroup
  waitGroup.Add(len(listOfTasks)) // add number of tasks to wait on

  for _, task := range listOfTasks {
    task(&waitGroup) // pass the WaitGroup via reference
  }

  waitGroup.Wait() // wait for completion
}
```

We're getting closer to our goal. Current output should be similar to

```
Done making hotel reservation.
Done booking flight tickets.
Done ordering a dress.
Done paying credit card bills.
Wrote a 1/3rd of the email.
Listened to 1/2 of the audio book.
Done listening to audio book.
Wrote a 2/3rds of the email.
Done writing the email.
```


#### Concurrent Task Execution

In the final output of the previous section, we can see that the `listOfTasks` are being executed
in serial order. The last step for maximum concurrency would be to let the order be determined
by the Go runtime instead of the order in `listOfTasks`. It sounds seriously complex, but it
really isn't. We just add `go` in front of the `task(&waitGroup)` call:

```go
func main() {
  var waitGroup sync.WaitGroup    // new WaitGroup
  waitGroup.Add(len(listOfTasks)) // add number of tasks to wait on

  for _, task := range listOfTasks {
    go task(&waitGroup) // pass the WaitGroup via reference, and call via goroutine
  }

  waitGroup.Wait() // wait for completion
}
```

Now your output should be more randomized, meaning that it is no longer executing serially.

```
Done booking flight tickets.
Listened to 1/2 of the audio book.
Done making hotel reservation.
Wrote a 1/3rd of the email.
Wrote a 2/3rds of the email.
Done writing the email.
Done paying credit card bills.
Done listening to audio book.
Done ordering a dress.
```

Now that we have a good idea on what concurrency is and how to write concurrent code with
`goroutines` and `WaitGroup`, let's dive into parallelism.

### Parallelism

Imagine you have to write a few emails, and they are going to be a bit of a job. So, you decide to
listen to music while writing them. The listening to music is "in parallel" to writing the emails.

Let's write a program to simulate this scenario.

```go
package main

import (
  "fmt"
  "sync"
  "time"
)

func printTime(msg string) {
  fmt.Println(msg, time.Now().Format("15:04:05"))
}

// Task that will be done over time
func writeMail1(wg *sync.WaitGroup) {
  printTime("Done writing mail #1.")
  wg.Done()
}
func writeMail2(wg *sync.WaitGroup) {
  printTime("Done writing mail #2.")
  wg.Done()
}
func writeMail3(wg *sync.WaitGroup) {
  printTime("Done writing mail #3.")
  wg.Done()
}

// Task done in parallel
func listenForever() {
  for {
    printTime("Listening...")
  }
}

func main() {
  var waitGroup sync.WaitGroup
  waitGroup.Add(3)

  go listenForever()

  // Give some time for listenForever to start
  time.Sleep(time.Nanosecond * 10)

  // Let's start writing the mails
  go writeMail1(&waitGroup)
  go writeMail2(&waitGroup)
  go writeMail3(&waitGroup)

  waitGroup.Wait()
}
```

Your program might output the following:

```
Done writing mail #3. 14:49:01
Listening... 14:49:01
Listening... 14:49:01
Done writing mail #1. 14:49:01
Listening... 14:49:01
Listening... 14:49:01
Listening... 14:49:01
Listening... 14:49:01
Done writing mail #2. 14:49:01
```

The numbers represent the time in terms of `Hours:Minutes:Seconds`, and (as can be seen), they
are being executed in _parallel_. You might think the code in the tasks concurrecny from earlier
looks a lot like this example, but the `listenForever` has an infinite loop. If you ran the above
without goroutines, we'd never stop listening.

So, that's the gist of how Go is allowing us to write concurrent programs.

## Go's Runtime Scheduler

The Go program, along with the runtime, is managed and executed on multiple OS threads. The
runtime uses a scheduler strategy known as **M:N**, which will schedule _M_ number of goroutines
on _N_ number of OS threads. This allows context switching to be fast, and also enables the use
of multiple cores of the CPU for parallel computing.

From the Go scheduler's perspective, there are three primary entities.

1. Goroutine (G)
1. OS thread or machine (M)
1. Context or processor (P)

### Goroutine

This is the logical unit of execution that contains the actual instructions for our programs and
functions to run. It also contains other important information regarding the goroutine, like the
stack memory, wich machine (M) it is running on, and which Go function called it.

Here are some of the elements in the goroutine sturct that might be worth knowing:


```go
// Denoted as G in runtime 
type g struct { 
    stack         stack // offset known to runtime/cgo 
    m               *m    // current m; offset known to arm liblink 
    goid           int64 
    waitsince   int64   // approx time when the g become blocked 
    waitreason string  // if status==Gwaiting 
    gopc          uintptr // pc of go statement that created this goroutine 
    startpc       uintptr // pc of goroutine function 
    timer         *timer  // cached timer for time.Sleep 
 
    // ... 
}
```

An interesting bit is that when our Go program starts, a goroutine called _main goroutine_ is
launched first, and it takes care of setting up the runtime space prior to executing the program.
Things like max stack size, garbage collection on/off, and so on.

### OS Thread or Machine

Initially, the OS threads or machines are created by and managed by the OS. Later on, the
scheduler can request more OS threads or machines to be created or destroyed. It is the actual
resource upon which a goroutine will be executed. It also maintains info about the _main
goroutine_, the G currently being run on it, **thread local storage (tls)**, and so on:

```go
// Denoted as M in runtime 
type m struct { 
    g0               *g         // goroutine with scheduling stack 
    tls               [6]uintptr // thread-local storage (for x86 extern register) 
    curg            *g         // current running goroutine 
    p                 puintptr   // attached p for executing go code (nil if not executing go code) 
    id                 int32 
    createstack [32]uintptr // stack that created this thread. 
    spinning      bool        // m is out of work and is actively looking for work 
 
    // ... 
}
```

### Context or Processor

We have a global scheduler which takes care of bringing up new M, registering G, and handling
system calls. However, it does not handle the actual goroutine execution. This is done by an
entity called **Processor**, whcih has its own internal scheduler and a queue called runqueue
(`runq` in code), consisting of goroutines that will be executed in the current context. It also
handles the switching between various goroutines and so on:

```go
// Denoted as P in runtime code 
type p struct { 
    id     int32 
    m     muintptr // back-link to associated m (nil if idle) 
    runq [256]guintptr 
 
    //... 
}
```

ⓘ From Go 1.5 and on, a Go runtime can have a max number of `GOMAXPROCS` Ps running at any given
point in the programs lifetime. Of course, we can change this number by either setting the
`GOMAXPROCS` env variable or by calling the `GOMAXPROCS()` function.

### Scheduling with G, M, and P

By the time the program is ready to start executing, the runtime has machines and processors set
up. The runtime would request the OS to start an ample number of (M)achines, `GOMAXPROCS` number
of (P)rocessors to execute (G)oroutines. _It is important to understand that M is the actual unit
of execution and G is the logical unit of execution._ They do require P to actually execute G
against the M.

Here's the components for the scenario:

* We have a set of M ready to run: M1...Mn.
* We have two Ps: P1 and P2 with runqueues - `runq1` and `runq2` respectively.
* We have 20 Goroutines, G1...G20, which we want to execute as part of the program.

Given that we have 2 Ps, the global scheduler would _ideally_ distribute the G between the two P
equally. Assume that P1 is assigned to work on G1...G10 and puts them into its runqueue, and
similarly P2 puts G11...G20 in its runqueue. Next, P1's scheduler pops a G from its runqueue to
run, G1, picks an M to run it on, M1, and similarly P2 runs G11 on M2.

A P's internal scheduler is also responsible for switching out the current G with the next one it
wants to execute. If all goes well, the scheduler will switch the current G for one of three
possible reasons:

1. Time slice for current execution is over: a P will use **schedtick** (incremented every time
the scheduler is called) to keep track of how long the current G has been executing, and, once
a certain time limit is reach, the G will be put back in the `runq` and the next G is picked up
for execution.
1. Done with execution: When the G is done executing all of its instructions. It will not be put
back in the `runq`.
1. Waiting on system call: In some cases, the G might need to make a system call, and as a result,
the G will be blocked. Given that we have limited P, it doesn't make sense to block. In Go, the P
is note required to wait on the system call; instead it can leave the waiting M and G combo,
and they will be picked up by the global scheduler after the system call. Then the P can pick
another M from the available ones, and another G from the `runq`, and start executing it.

### Scheduler Strategy: Work-Stealing

Let's say that P1 has 10 G and P2 has 10 G, but P1 completes long before P2. With the help of the
work-stealing strategy, P1 starts checking with other Ps and, if there are Gs in their `runq`, it
will "steal" half of them and start executing them. This ensures that we are maximizing the CPU
usage for our program.

If the P realizes it can't steal any more tasks, it will idle for a while expecting new G and, if
none are created, the P is killed.

Also, a P will only ever steal half of the target P's `runq`, no more, no less.

## Gotchas When Using Goroutines

Now that we know a fair bit about the scheduler and how it works with goroutines, let's raise
awareness of some potential pitfalls.

### Single Goroutine Halting the Complete Program

We know that G run across many P and M, so what happens when one of the threads has a panic?
Let's simulate that with the following code, where we have a lot of similar G, whose sole purpose
us to take a number and divide it by iteself after subtractiong 10 from the denominator. It will
work great _unless_ the number is `10`.

```go
package main 
 
import ( 
    "fmt" 
    "sync" 
) 
 
func simpleFunc(index int, wg *sync.WaitGroup) { 
    // This line should fail with Divide By Zero when index = 10 
    fmt.Println("Attempting x/(x-10) where x = ", index, " answer is : ", index/(index-10)) 
    wg.Done() 
} 
 
func main() { 
    var wg sync.WaitGroup 
    wg.Add(40) 
    for i := 0; i < 40; i += 1 { 
        go func(j int) { 
            simpleFunc(j, &wg) 
        }(i) 
    } 
 
    wg.Wait() 
}
```

You'll see something akin to the following:

```
Attempting x/(x-10) where x =  39  answer is :  1
Attempting x/(x-10) where x =  20  answer is :  2...
Attempting x/(x-10) where x =  37  answer is :  1
Attempting x/(x-10) where x =  11  answer is :  11
panic: runtime error: integer divide by zerogoroutine 15 [running]:main.simpleFunc(0xa, 0xc42000e280)        
...exit status 2
```

So, essentially, a lot of G were put in the `runq`, and everything went swell until the G with 
`index` of `10` was executed, and it raised a panic that was not handled by the function. Thus
resulting in the entire programming being halted, with an exit status of `2`.

That's not very graceful, so we should get that sorted out. Go has a function named `recover`
that will assist.

```go
package main 
 
import ( 
    "fmt" 
    "sync" 
) 
 
func simpleFunc(index int, wg *sync.WaitGroup) { 
    // functions with defer keyword are executed at the end of the function 
    // regardless of whether the function was executed successfully or not. 
    defer func() { 
        if r := recover(); r != nil { 
            fmt.Println("Recovered from", r) 
        } 
    }() 
 
    // We have changed the order of when wg.Done is called because 
    // we should call upon wg.Done even if the following line fails. 
    // Whether a defer function exists or not is dependent on whether it is registered 
    // before or after the failing line of code. 
    defer wg.Done() 
    // This line should fail with Divide By Zero when index = 10 
    fmt.Println("Attempting x/(x-10) where x = ", index, " answer is : ", index/(index-10)) 
} 
 
func main() { 
    var wg sync.WaitGroup 
    wg.Add(40) 
    for i := 0; i < 40; i += 1 { 
        go func(j int) { 
            simpleFunc(j, &wg) 
        }(i) 
    } 
 
    wg.Wait() 
}
```

Output will be akin to:

```
Attempting x/(x-10) where x =  11  answer is :  11
Recovered from runtime error: integer divide by zero
Attempting x/(x-10) where x =  33  answer is :  1
Attempting x/(x-10) where x =  34  answer is :  1
```

### Goroutines Are Not Predictable

Consider the code from the _Parallelism_ section earlier on.  Here's a reminder:

```
Done writing mail #3. 19:32:57
Listening... 19:32:57
Listening... 19:32:57
Done writing mail #1. 19:32:57
Listening... 19:32:57
Listening... 19:32:57
Done writing mail #2. 19:32:57
```

If we changed `GOMAXPROCS` to 1 or the system has low hardware capabilities, it is possible that
it may lead to the G printing `Listening...` to run forever. In reality, the Go compiler should
detect this case, but it would be better to plan the code so we don't have to rely on Go's 
scheduler.

[🔙 Development Environment for Go][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Channels and Messages 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch01-development-environment-for-go.md
[upcoming-chapter]: ch03-channels-and-messages.md
[go-blog]: https://blog.golang.org/concurrency-is-not-parallelism
[go-youtube]: https://www.youtube.com/watch?v=cN_DpYBzKso
[concurrency-vs-parallelism]: images/ch02-concurrency-vs-parallelism.png

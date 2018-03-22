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

## Go's Runtime Scheduler

### Goroutine

### OS Thread or Machine

### Context or Processor

### Scheduling with G, M, and P

## Gotchas When Using Goroutines

### Single Goroutine Halting the Complete Program

### Goroutines Are Not Predictable

[🔙 Development Environment for Go][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Channels and Messages 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch01-development-environment-for-go.md
[upcoming-chapter]: ch03-channels-and-messages.md
[go-blog]: https://blog.golang.org/concurrency-is-not-parallelism
[go-youtube]: https://www.youtube.com/watch?v=cN_DpYBzKso
[concurrency-vs-parallelism]: images/ch02-concurrency-vs-parallelism.png

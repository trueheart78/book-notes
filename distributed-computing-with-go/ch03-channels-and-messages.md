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

### Distributed Work With Channels

#### What Is a Channel?

#### Solving the Cashier Problem with Goroutines

### Channels and Data Communication

#### Messages and Events

### Types of Channels

#### The Unbuffered Channel

#### The Buffered Channel

#### The Unidirectional Buffer

### Closing Channels

### Multiplexing Channels

[🔙 Understanding Goroutines][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[The RESTful Web 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch02-understanding-goroutines.md
[upcoming-chapter]: ch04-the-restful-web.md

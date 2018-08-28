# Concurrency Use Cases

* If you know the number of elements prior to running Gs, consider a bC.
* If each G takes about the same amount of time, and there could be potential waiting, then buffering
makes sense.
* If an earlier stage of an assembly line is consistently faster than a following stage, a buffer is
going to be full more often.
* If a later stage of an assembly line is consistently faster than an earlier stage, the buffer is
most likely going to be empty and will provide little benefit.
* If not all elements of a C will be used, a bC is the better option. A uC will cause a G leak bug.
  * Consider how checking the speed of known mirrors and returning just the first response works.
* uC's are designed around synchronization between Gs, and less about handling a buffer.
  * Sending on a uC immediately calls any G receiving on the uC.

## Coming From Nested Loops

In many languages, implementing safe concurrency can be problematic. In these languages, it is not
uncommon to use nested loops with some arrays/hashes/maps to get some work done. When we get to Go,
however, safe concurrency is readily available. Therefore, instead of finding yourself using nested
loops with data in slices/maps, you can use a C (bC or uC) with the help of `sync.WaitGroup` to get 
similar work done.

## Programs Too Parallel & Counting Semaphores

Remember that parallelism can exhaust OS resources, and using a _counting semaphore_ (read: bC) to
limit the number of active Gs can solve many a problem.

Some programs can be too parallel, meaning that they cause issues when allowed to run unchecked and
unlimited. Something like a web crawler can exhaust open file ops which in turn can cause TCP sockets
to be unable to create new connections. In these cases, you have to judge _how_ to limit things.

An arbitrary number can be determined, or you potentially have access to resources to verify the
limit (like an ENV var, or maybe a resource check). Regardless, you have to use something to do this,
and a _counting semphore_ can be helpful. It's basically a bC that is sent to prior to any I/O and
then received from directly after said I/O.

```go
var tokens = make(chan struct{}, 20)

tokens <- struct{}{} // acquire a token
list, err := links.Extract(url)
<-tokens // release the token
```

## Multiplexing with `select`

_tbd_
Sometimes, you are listening on multiple Cs, and having cases (especially default cases) can
provide assistance in fine-tuning how you want your G to run. Blocking, non-blocking. You've now 
got options.

## Cancellation with Channels

Tying in the ability to cancel long-running apps can be very helpful. This is where using a closed
C to notify Gs that may still have things to do makes sense. It can check the C using a `select`
(or by calling a polling fn like `cancelled()`) and know whether it should return early or not.

## Notes from [Channels](ch062-channels.md)

The choice between uC and bC, and a bC's capacity, may both affect the correctness of an app. uC
gives strong sync guarantees because every send op is sync'd with its corresponding receive; with bCs
these are decoupled. Also, on a bC the upper bound is known, it's not unusual to create a bC of that
size and perform all the sends before the first val is received. Failure to allocate proper capacity
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

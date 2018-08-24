# Concurrency Use Cases

* If you know the number of elements prior to running Gs, consider a bC.
* If each G takes about the same amount of time, and there could be potential waiting, then buffering
makes sense.
* If an earlier stage of an assembly line is consistently faster than a following stage, a buffer is
going to be full more often.
* If a later stage of an assembly line is consistently faster than an earlier stage, the buffer is
most likely going to be empty and provide little benefit.
* If not all elements of a C will be used, a bC is the better option. A uC will cause a G leak bug.
  * Consider checking the speed of known mirrors and returning just the first response.
* uC's are designed around synchronization between Gs, and less about handling a buffer.
  * Sending on a uC immediately calls any G receiving on the uC.

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
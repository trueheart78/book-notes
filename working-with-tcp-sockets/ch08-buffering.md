[&lt;&lt; Back to the README](README.md)

# Chapter 8. Buffering

Questions to answer:

* How much data should I read/write with a single call?
* If `write` returns successfully does that mean that the other end of the
  connection received my data?
* Should I split a big `write` into a bunch of smaller writes?

## Write Buffers

What really happens when you `write` data on a TCP connection?

When `write` returns, it oly means that it has acknowledged that you have left
your data in the capable hands of Ruby's IO system and the underlying kernel.

There is at least one layer of buffers between your app code and actual network
hardware.

When `write` returns successfully, the only guarantee you have is that your
data is now in the capable hands of the OS kernel. It is something you have
delegated, and trust that it will be handled properly.

By default, Ruby sockets set `sync` to true, skipping Ruby's internal
buffering, which would otherwise add another layer of buffers. View my 
[Screencast: Ruby's IO Buffering And You!](http://www.jstorimer.com/blogs/workingwithcode/7766075-screencast-rubys-io-buffering-and-you) online.

### Why Buffer At All?

All layers of IO buffering are in place for performance reasons, generally
offering *big* improvements in performance.

Sending data across the network is slow. Really slow. Buffering allows calls to
`write` to return almost immediately. Then, behind the scenes, the kernel can
collect all pending writes, group them and optimize them when they're sent to
achieve maximum perforamnce, so as to not flood the network. At the network
level, each request has overhead, so many requests would mean a lot of overhead.

## How Much to Write?

Given what we now know abouve buffering, let's ask ourselves: should I do many
small `write` calls, or one really big `write` call?

Thanks to the way buffers work, we don't have to think of it. If you are doing
a *really* big `write` (like files, or big data), then consider splitting up
the data, otherwise, it can consume RAM.

In general, **you'll get the best performance from writing everything you have
to write in one go** and letting the kernel handle how to chunk the data.

## Read Buffers

Reads are also buffered.

When you ask Ruby to `read` data from a TCP connection and pass a maximum read
length, Ruby actually may be able to receive more data than your limit allows.

In this case, that 'extra' data will be stored in Ruby's internal buffers.

## How Much to Read?

Since TCP provides a stream of data, we don't know how much is coming from the
sender. 

Why not use a huge read length? We can easily use more resources if we require
more than we need.

If we specify a small read length, we incur overhead for each call are made.

So, as with most things, it depends. Tune your program based on the data it
receives.

Mongel, Unicorn, Puma, Passenger, Net::HTTP, and they all do a
`readpartial(1024 * 16)`. They all use 16KB as their read length.

Redis uses just 1KB as its read length.

So, as with most things: it depends. However, a good starting point would be
the 16KB length listed above, and tune it from there.

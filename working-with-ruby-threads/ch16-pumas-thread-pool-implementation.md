[&lt;&lt; Back to the README](README.md)

# Chapter 16. Puma's Thread Pool Implementation

[Puma](http://puma.io) is a concurrent web server for Rack apps that uses
multiple threads for concurrency.

At Puma's multi-threaded core is a thread pool implementation.

## A What Now?

Puma's thread pool is responsible for spawning the worker threads and feeding
them work. The thread pool wraps up all of the multi-threaded concerns so the
rest of the server is just concerned with networking and the actual domain
logic.

FYI, `Puma::ThreadPool` is a totally generic class, not Puma specific.

Once intitialized, the pool is responsible for receiving work and feeding it
to an available worker thread. It also has an auto-trimming feature, whereby
the number of active threads is kept to a minimum, but more threads can be
spawned during times of high load.

## The Whole Thing.

This gets called once for each worker thread to be spawned for the pool.

Note: One instance of this class will spawn many threads.

```rb
def spawn_thread
  @spawned += 1

  th = Thread.new do
    todo = @todo
    block = @block
    mutex = @mutex
    cond = @cond

    extra = @extra.map { |i| i.new }

    while true
      work = nil
      continue = nil

      mutex.synchronize do
        while todo.empty?
          if @shutdown
            continue = false
            break
          end

          @waiting += 1
          cond.wait mutex
          @waiting -= 1
        end

        work = todo.pop if continue
      end

      break unless continue

      block.call(work, *extra)
    end

    mutex.synchronize do
      @spawned -= 1
      @workers.delete th
    end
  end

  @workers << th

  th
end
```

## In Bits

In the source file, there is a very important comment right about this method:

```rb
# must be called with @mutex held!
```

This is why it can use this non-thread-safe operator initially to increment
the `@spawned` variable. The mutex is opt-in.

At the start of the `th = Thread.new do` section, many assignments happen,
and they are mainly to push local variables the same data that is in the instance
wariables, and this comes down to a performance reason, not a thread-safety one.



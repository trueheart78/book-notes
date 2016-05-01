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

```rb
while true
  work = nil
  continue = true
```

The first line enters an infinite loop, so it will continue to execute until it
hits its exit condition further down.

```rb
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
```

All the code in this block happens inside of the `mutex.synchronize`, so other
threads have to wait while the current thread executes this block.

The internal block only runs if `todo` is empty. If it is empty, there is not
any work that needs to be done.

If there's no work to do, this workier thread will check to see if it should
shut down.

If it doesn't need to shutd down, things get more interesting.

First, it increments a global counter identifying that it's going to wait. Next,
it waits on the shared condition variable, which releases the mutex and puts
the current thread to sleep.

Also, notice that a `while` loop is used as the outer construct here, rather than
an `if` statement. The condition variable should be re-checked to ensure that
another thread hasn't done the work.

Once work arrives, this thread gets woken up. As part of being signaled by the
condition variable, it will re-acquire the shared mutex, which once again makes
it safe to decrement the global counter.

```rb
mutex.synchronize dp
  @spawned -= 1
  @workers.delete th
end
```

The body of the thread ends with a little housekeeping. Once the thread leaves
its infinite loop, it needs to re-acquire the mutex to remove its reference
from some shared variables.

```rb
@workers << th

th
```

The last two lines are outside the scope of the block passed to `Thread.new`.
So they'll execute immediately after the thread is spawned. And remember, even
here the mutex is held by the caller of this method.

The current thread is added to `@workers`, then returned.

## Wrap-Up

Puma does a superb job of isolating the concurrency-primitive logic from the
actual domain logic of the server. You should check out how the `ThreadPool`
is used in Puma, and the lack of threading primitives through the rest of the
codebase.

Also, check out other methods in the `ThreadPool` class, tracing the flow from
initialization, to work units being added to the thread pool, to work units
being processed from the thread pool, all the way to shutdown.

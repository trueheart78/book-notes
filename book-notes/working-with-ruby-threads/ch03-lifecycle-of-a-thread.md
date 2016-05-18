[&lt;&lt; Back to the README](README.md)

# Chapter 3. Lifecycle of a Thread

## require 'thread'

```rb
puts defined?(Thread) #=> constant
puts defined?(Queue)  #=> nil

require 'thread'
```

Notice how `Thread` is already loaded before the require? Because the require
brings in stuff like `Queue`.

## Thread.new

Spawn a thread by passing a block to `Thread.new` (or an alias) and optionally
passing in block variables like you can with `Thread.start`

```rb
Thread.new { ... }
Thread.fork { ... }
Thread.start(1, 2) { |x, y| x + y }
```

**Executes the block:** You pass a block when spawning the thread. Either it will
reach the end of the block or raise an exception, terminating in either case.

**Returns an instance of `Thread`:** Like all good constructors, `Thread.new`
returns a new instance.

## Thread#join

Once you have spawned a thread, `#join` can be used to wait for it to finish.

```rb
thread = Thread.new { sleep 3 }
thread.join
puts 'You will see this after 3 seconds'
```

You could run the code without the `#join`, but you might need to wait on it
to finish so you can continue on. Also, the main thread would exit before the
thread would finish executing its block. Using `#join` guarantees it will be
done.

**Calling `#join` on the spawned thread will join the current thread of execution
with the spawned one.** So where there were previously two independed threads,
now the current thread will sleep until the spawned thread exits.

### Thread#join and Exceptions

A thread can terminate in two ways. The happy path of completing code execution,
and the unhappy path of an unhandled exception.

**When one thread raises an unhandled exception, it terminates the thread where
the exception was raised, but doesn't affect other threads.**

And a thread that crashes from an unhandled exception won't be noticed until
another thread attempts to join it. :boom:

```rb
thread = Thread.new do
  raise 'hell'
end

# simulate work, and see the exception is unnoticed currently
sleep 3

# this will re-raise the exception in the current thread
thread.join
```

When one thread has crashed with an unhandled exception, and another thread
attempts to join it, the exception is re-raised in the joining thread.

The exception will also be at the correct spot where it occurred, not where
the join happened.

## Thread#value

Very similar to `#join`, `#value` first joins with the thread, and then returns
the last expression from the block of code the thread executed.

```rb
thread = Thread.new do
  40 + 2
end

puts thread.value #=> 42
```

The value method has the same properties as `#join` regarding unhandled
exceptions because it actually calls `#join`. **The only difference is in the
return value.**

## Thread#status

A thread can check another threads status, or even its own (`Thread.current.status`).

Possible values returned for `#status`

- `run`: Currently running.
- `sleep`: Sleeping, blocked waiting for a mutex, or waiting on IO.
- `false`: Finished executing code, or were successfully killed.
- `nil`: Has raised an unhandled exception. 
- `aborting`: Currently running, yet dying.

## Thread.stop

Puts the current thread to sleep *and* tells the thread scheduler to schedule
another thread. Gets woken up by `#wakeup`

```rb
thread = Thread.new do
  Thread.stop
  puts 'Hello'
end

nil until thread.status == 'sleep'

thread.wakeup
thread.join
```

## Thread.pass

Kind of like `Thread.stop`, but doesn't put the current thread to sleep. Can't
guarantee the thread scheduler will pass on it.

## Avoid Thread#raise

**Don't use this method.** It doesn't properly respect `ensure` blocks.

Also, gives less than stellar info in the backtrace that can be hard to work with.

## Avoid Thread#kill

See the notes on `Thread#raise` right above.

## Supported Across Implementations

`Thread` is a Ruby API. **All Ruby implementations covered here support the
same `Thread` API.**

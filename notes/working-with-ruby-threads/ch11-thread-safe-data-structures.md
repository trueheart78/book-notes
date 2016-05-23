[&lt;&lt; Back to the README](README.md)

# Chapter 11. Thread-Safe Data Structures

## Implementing a Thread-Safe, Blocking Queue

The idea is this:

```rb
q = BlockingQueue.new
q.push 'thing'
q.pop #=> 'thing'
```

Straightforward, and you also don't want users of `BlockingQueue` to have to
use a mutex. It should be internally thread-safe.

Also, `BlockingQueue#pop` should block when called on an empty queue, until
something is pushed onto it.

```rb
require 'thread'

class BlockingQueue
  def initialize
    @storage = Array.new
    @mutex = Mutex.new
    @condvar = ConditionVariable.new
  end

  def push(item)
    @mutex.synchronize do
      @storage.push(item)
      @condvar.signal
    end
  end

  def pop
    @mutex.synchronize do
      while @storage.empty?
        @condvar.wait(@mutex)
      end

      @storage.shift
    end
  end
end
```

Note: There is no need for a global mutex here. Different instances of this
class will provide their own thread-safety guarantees. So while once instance
is pushing data into its `Array`, there's no problem with another instance
pushing data into its `Array` concurrently. The issue only arises when the
concurrent modification is happening on the same instance.

## Queue, from the Standard Lib

Ruby ships with a class called `Queue`. **This is the only thread-safe data
structure that ships with Ruby.** It is part of the `require 'thread'` utilities.

`Queue` is very similar to the `BlockingQueue` above, but has a few more methods.
Its behavior regarding `push` and `pop` is exactly the same.

`Queue` is very useful because of its blocking behavior. You would use a `Queue`
to distribute workloads to multiple threads, with one thread pushing to the
queue, and multiple threads popping. The popping threads are put to sleep until
there's some work for them to do.

```rb
require 'thread'

queue = Queue.new

producer = Thread.new do
  10.times do
    queue.push(Time.now.to_i)
    sleep 1
  end
end

consumers = []

3.times do
  consumers << Thread.new do
    loop do
      unix_timestamp = queue.pop
      formatted_timestamp = unix_timestamp.to_s.reverse.
                            gsub(/(\d\d\d)/, '\1,1).reverse
      puts "It has been #{formatted_timestamp} since the epoch!"
    end
  end
end

producer.join
```

## Array and Hash

**Ruby does not ship with any thread-safe Array or Hash implementations.**

Even the JRuby `Array` and `Hash` are not thread-safe.

In Ruby, you can use a thread-safe `Array` or `Hash` by using the
[`thread_safe` gem](https://github.com/ruby-concurrency/thread_safe), with
the following versions under its own namespace.

- `ThreadSafe::Array` can be used in place of `Array`.
- `ThreadSafe::Hash` can be used in place of `Hash`.

They are not re-implmentations; they actually wrap the core Array and Hash,
ensuring each method call is protected by a Mutex.

## Immutable Data Structures

These are inherently thread-safe. More in the appendix on *Immutability.*


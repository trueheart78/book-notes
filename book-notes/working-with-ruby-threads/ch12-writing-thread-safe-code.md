[&lt;&lt; Back to the README](README.md)

# Chapter 12. Writing Thread-Safe Code

This chapter should be your guideline to writing thread-safe code.

> Idiomatic Ruby code is most often thread-safe Ruby code.

## Avoid Mutating Globals

Sharing objects between threads is where issues can arise in a multi-threaded
context. Global objects should stick out like a sore thumb.

Note thread-safe:

```rb
$counter = 0
puts 'Threads use me!'
```

1. Even globals can provide thread-safe guarantees.
2. Anytime there is only one share instance (aka singleton), it's a global.

### Even Globals Can Provide Thread-Safe Guarantees

You could easily define a class that uses a mutex to make the global counter
thread-safe. More code, but worth it.

```rb
require 'thread'

class Counter
  def initialize
    @counter = 0
    @mutex = Mutex.new
  end

  def increment
    @mutex.synchronize do
      @counter += 1
    end
  end
end
```

### Anything Where There is Only One Shared Instance is a Global

There are other things that fit into this definition in Ruby.

- Constants
- The AST
- Class variables/methods

Just like storing a counter in a global variable (that has no thread-safety
guarantee) is *not* safe, the same is true of you store that counter in a class
variable or constant. Look for those instances too.

This is OK, because it doesn't modify global state.

```rb
class RainyCloudFactory
  def self.generate
    cloud = Cloud.new
    cloud.rain!
    
    cloud
  end
end
```

This is *not* ok, because it does modify global state.

```rb
class RainyCloudFactory
  def self.generate
    cloud = Cloud.new
    @@clouds << cloud

    cloud
  end
end
```

**Modifying the AST at runtime is almost always a bad idea**, especially when
multiple threads are involved.

## Create More Objects, Rather Than Sharing One

Sometimes you just need that global object. Think of a long-lived connection
to a database or external service, not a one-off HTTP request.

The db client needs to jump through a lot of hoops to make sure that the right
thread receives the right result, or...

The simpler solution is to create more connections. There are two useful
concepts you could use:

1. Thread-locals
2. Connection pools

### Thread Locals
 
 **A thread-local lets you define a variable that is global to the scope of the
 current thread.**

In other words, it is a global variable that is locally scoped on a per-thread
basis.

```rb
# Instead of
$redis = Redis.new

# use
Thread.current[:redis] = Redis.new
```

This keeps the connection local to the thread. You could use this for more than
Redis, but it may not scale well if you need tons of processes, as it can cause
issues with the number of open connection limits at the other end.

### Resource Pools

In the above Redis example, if you have N threads, you could use a pool of M
connections to share among those threads, where M is less than N. **This still
ensures that your threads aren't sharing a single connection, but doesn't
require each thread to have its own.**

A pool object will open a number of connections, or may allocate a number of
any kind of resource that needs to be shared among threads. When a thread wants
to make use of a connection, it asks the pool to check out a connection. The
pool is resoponsible for keeping track of which connections are checked out,
and which are available, preserving thread-safety. When the thread is done, it
checks the connection back into the pool

Take a look at the
[`connection_pool` gem](https://github.com/mperham/connection_pool) for a good
study in this area.

## Avoid Lazy Loading

Autoloading like Rails can be problematic in the presence of multiple threads,
in earlier versions of Ruby. We're talking autoloading of files/classes.

In later versions of Ruby 2.0.0 it was patched to be thread-safe.

## Prefer Data Structures Over Mutexes

Mutexes are hard to use correctly.

- How coarse or fine should this mutex be?
- Which lines of code need to be in the critical section?
- Is a deadlock possible here?
- Do I need a per-instance mutex? Or a global one?

You may understand these concerns, and have them under your control, but other
developers you work with also need to be aware of them, if you use them. So
using a data structure can remove a lot of these concerns.

**Rather than worrying about where to put the mutex, it's deadlock capabilities,
you simple don't need to create any mutexes in your code.**

Rather than letting threads access shared objects and implementing the
necessary synchronization, you pass shared objects through data structures. This
ensures that only one thread could mutate an object at any given time.

## Finding Bugs

This kind of debugging can often feel like looking fr a needle in a haystack.

Reproducing it always helps, if possible, but some will only appear in production
under heavy load, and can't be reproduced locally.

Global references are a notable problem, and that is often the best place to
start. Look at the code and assume that 2 threads will be accessing it at the
same time. Step through the possible scenarios. Write these down.

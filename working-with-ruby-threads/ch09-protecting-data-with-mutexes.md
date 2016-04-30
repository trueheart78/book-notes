[&lt;&lt; Back to the README](README.md)

# Chapter 9. Protecting Data with Mutexes

Mutexes provide a mechanism for multiple threads to synchonize access to a
critical postion of code.

## Mutual Exclusion

Mutex is short for 'mutual exclusion'. If you wrap some section of your code
with a mutex, you guarantee that no two threads can enter that section at
the same time.

That array example from the last chapter, updated accordingly.

```rb
shared_array = Array.new
mutex = Mutex.new

10.times.map do
  Thread.new do
    1000.times do
      mutex.lock
      shared_array << nil
      mutex.unlock
    end
  end
end.each(&:join)

puts shared_array.size
```

And you get correct results across Ruby implementations every time.

```
$ ruby code/snippets/concurrent_array_pushing.rb
10000
$ jruby code/snippets/concurrent_array_pushing.rb
10000
$ rbx code/snippets/concurrent_array_pushing.rb
10000
```

The thread that hits the `mutex.lock` first gains ownership until it is unlocked,
meaning no other thread can enter that postion of code.

A bit cleaner syntax:

```rb
mutex.synchronize do
  shared_array << nil
end
```

You pass a block to `Mutex#synchronize` and it will lock it, call the block,
and then unlock the mutex.

## The Contract

Notice the mutex is shared among all the threads. They must be sharing the
**same mutex instance**.

No change was require to `<<` or `shared_array`, either.

The block inside of a `Mutex#synchronize` call if often termed a **critical
section**, because the code accesses a shared resource and must be handled
correctly.

## Making Key Operations Atomic

You can use a mutex to make check-then-set race conditions thread-safe.

```rb
class Order
  attr_accessor :amount, :status

  def initialize(amount, status)
    @amount, @status = amount, status
    @mutex = Mutex.new
  end

  def pending?
    status == 'pending'
  end
  def collect_payment
    @mutex.synchronize do
      puts "Collecting payment..."
      self.status = 'paid'
    end
  end
end

order = Order.new(100.00, 'pending')

# Ask 5 threads to check the status, and collect # payment if it's 'pending'
5.times.map do
  Thread.new do
    if order.pending?
      order.collect_payment
    end
  end
end.each(&:join)
```

Each `Order` now has its own `Mutex`, initialized when the object is created.

**Look at it not helping at all...**

```
$ ruby code/snippets/concurrent_payment.rb
Collecting payment...
Collecting payment...

$ jruby code/snippets/concurrent_payment.rb
Collecting payment...
Collecting payment...

$ rbx code/snippets/concurrent_payment.rb 
Collecting payment...
Collecting payment...
```

The reason is that the critical section is in the wrong place. Multiple threads
could be past the 'check' phase of the 'check-and-set' race condition.

Both the 'check' AND the 'set' are required inside the mutex.

```rb
class Order
  attr_accessor :amount, :status

  def initialize(amount, status)
    @amount, @status = amount, status
  end

  def pending?
    status == 'pending'
  end
  def collect_payment
    puts "Collecting payment..."
    self.status = 'paid'
  end
end

order = Order.new(100.00, 'pending')
mutex = Mutex.new

# Ask 5 threads to check the status, and collect # payment if it's 'pending'
5.times.map do
  Thread.new do
    mutex.synchronize do
      if order.pending?
        order.collect_payment
      end
    end
  end
end.each(&:join)
```

The change here is that the mutex is now used inside the block passed to
`Thread.new`, not inside the `Order` object. It is now a contract between
threads, rather than a contract enforced by the object.

The multi-step operation of checking if an `Order` is pending is now
atomic.

```
$ ruby code/snippets/concurrent_payment.rb
Collecting payment...

$ jruby code/snippets/concurrent_payment.rb
Collecting payment...

$ rbx code/snippets/concurrent_payment.rb 
Collecting payment...
```

## Mutexes and Memory Visibility

Should the same shared mutex be used when a thread tries to read the order
status?

**If you are setting a variable while holding a mutex, and other threads want to
see the most current value of that variable, they should also perform the read
while holding the mutex.**

A **memory barrier** is the solution. Mutexes are implemented with memory barriers,
so that when they are locked, a memory barrier provides the proper memory
visibility semantics.

```rb
# this could be stale
status = order.status

# this line is guaranteed to be consistent with other threads
status = mutex.synchronize { order.status }
```

Ruby doesn't have a memory model specification. However, **mutexes carry an
implicit memory barrier**.

## Mutex Performance

Mutexes inhibit parallelism.

Critical sections of code that are protected can only be executed by one thread
at any given time. This is why the GIL inhibits parallelism. The GIL is just a
mutex.

Mutexes provide safety where needed, but at the cost of performance. Nothing
is more important that making sure your data is not corrupted through race
conditions, but you want to **restrict the critical section to be as small
as possible, while still preserving the safety of your data.** This allows
as much code as possible to execute in parallel.

A finer grained mutex around data changes is more correct than around just
entire blocks of code. It has to do with the data being changed in a critical
section. Note that using `Queue` instead of `Array` could also keep data
thread-safe.

**Put as little code in your critical sections as possible, just enough to
ensure that your data won't be modified by concurrent threads.**

## The Dreaded Deadlock

A deadlock means 'game over' for the system in question.

A deadlock occurs when one thread is blocked waiting for a resource from
another thread (like blocking on a mutex), while that thread is also blocked
waiting for a resource. The system comes to a place where no progress can
happen.

`Mutex#try_lock` can be used to attempt to lock a mutex, and returns `true`
or `false` accordingly.

You can still end up in a **livelock, where the system is not progressing,
becayse the threads are stuck in a loop with each other.**

Use a **mutex hierachy**. **Any time two threads need to acquire multiple
mutex, make sure they do it in the same order.** This will avoid deadlock.



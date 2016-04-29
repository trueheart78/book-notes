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

[&lt;&lt; Back to the README](README.md)

# Chapter 8. Thread Safety

If a program isn't thread-safe, what will happen?

Will the app crash? Will the server burn up? Will subtle bugs be magically
introduced at a slow but consistent rate, without any possibility of
reproducing them?

## What's Really at Stake?

Your data is. Not your DB data, per se, but the values your app has stored in
memory.

**When your code isn't thread-safe, the worst that can happen is that your
underlying data becomes incorrect**, but your app doesn't know.

- If your code is 'thread-safe', that means you can run your code in a multi-
  threaded context and your underlying data will be safe.
- If your code is 'thread-safe', that means you can run your code in a multi-
  threaded context and your underlying data remains consistent.
- If your code is 'thread-safe', that means you can run your code in a multi-
  threaded context and the semantics of your app are always correct.

Concrete example time:

```rb
Order = Struct.new(:amount, :status) do
  def pending?
    status == 'pending'
  end
  def collect_payment
    puts "Collecting payment..."
    self.status = 'paid'
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

This is a variant of a **check-then-set** race condition.

Some sample output looks like...

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

Charging multiple times for an order would be very bad.

This sample code will continually give you different, yet incorrect, results.
That's what happens when you don't synchronize access to the `order`.

What happened? Context switching directly after checking the `order.pending?`.

This type of operation needs to be made atomic, so the thread scheduler can
understand this multi-step operation should not be interrupted.

## The Computer is Oblivious

The computer is unaware of thread-safety issues. **The onus is on you to notice
these problems and handle them.**

This has to be one of the hardest problems when it comes to thread safety. There
are no exceptions raised or alarm bells rung when the underlying data is no
longer correct. Even worse, sometimes it takes a heavy load to expose a race
condition like this. This could be skipped in development and only noticed in
a critical time during production.

## Is Anything Thread-Safe by Default?

In Ruby, very few things are *guaranteed* to be thread-safe by default.

Not only are compound operators in Ruby un-atomic, things like `Array` and `Hash`
are not thread-safe by default.

```rb
shared_array = Array.new

10.times.map do
  Thread.new do
    1000.times do
      shared_array << nil
    end
  end
end.each(&:join)

puts shared_array.size
```

A silly example with 10 threads appending 1,000 elements to a shared `Array`.
Should just be `10 * 1,000 = 10,000` elements.

```
$ ruby code/snippets/concurrent_array_pushing.rb
10000
$ jruby code/snippets/concurrent_array_pushing.rb
7521
$ rbx code/snippets/concurrent_array_pushing.rb
8541
```

Again, an incorrect result with no exceptions raised by Ruby.

**Remember that any concurrent modifications to the same object are not
thread-safe.** This includes things like adding an `Array` element, or even
regular old assignment.

In any of these situations, your underlying data is not safe if that operation
will be performed on the same region of memory by multiple threads.

**This is not nearly as scary as it sounds.** This is just the scary side of
the coin.

These operations are fine to use in a threaded program so long as you can
guarantee that multiple threads won't be performing the same modification
to the same object at the same time.

The good news is that, most of the time, just writing good, idiomatic Ruby will
lead to thread-safe code.

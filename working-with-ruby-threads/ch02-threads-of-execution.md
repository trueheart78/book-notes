[&lt;&lt; Back to the README](README.md)

# Chapter 2. Threads of Execution

Need a new thread? Easy!

```rb
Thread.new { "Did it!" }
```

Multi-threaded programming is not as simple as just spawning more threads. There
are a fair amount of concerns:

- When and where should I spawn them?
- How many should I spawn?
- What about thread safety?

Threads are powerful, but can be dangerous if you don't know what you're doing.

## Shared Address Space

**Threads have a shared address space.** They will all share the same references
in memory, as well as the compiled source code.

A conditional assignment `||=` can cause problems in a multi-threaded context.

## Many Threads of Execution

We typically write code with a sequential set of instructions.

It can be hard to grasp that there can be multiple threads of execution
operating on the same code *at the same time*.

**It's as if someone just changed the rules of physics on you: things that were
previously absolute truths no longer hold true.**

Thread scheduling have a certain amount on randomness.

Don't lose hope, though.

## Native Threads

All provided Ruby implementations shown in this book map one Ruby thread to one
native, OS-level thread.

```rb
100.times do
  Thread.new { sleep }
end

puts Process.pid
sleep
```

You can run `top -l1 -pid 8409 -stats pid,th` (using your process id) to see
that we created 100 threads, plus the main thread, and MRI's internal thread,
which is 102. They are all handle directly by the OS.


## Non-deterministic Context Switching

This title is a fancy title, and it refers to the work that's done by your OS
thread scheduler. You have no control over how it functions. It is responsible
for scheduling *all* of the threads running on the system.

**In order to provide fair access, the thread scheduler can 'pause' a thread at
any time**, suspending its current state. This is context-switching.

You can have your app say, "Hey, threadscheduler, I'm doing something important
here, don't let anybody else cut in until I'm done."

## Context Switching in Practice

Because of how `||=` works, it's possible for threads to be paused in the middle
of the operation, causing potential data loss (or repetition).

An easy fix is, for thread safe code, to instantiate the `@variable` in `initialize`
instead of lazily.

**This is what is known as a race condition. Can be very hard to track down.**

> A race condition involves two threads racing to perform an operation on some shared state.

It is inherently non-deterministic.

**Atomic operations** cannot be interrupted before it's complete. `||=` is not
atomic.

## Why is this So Hard?

Should you stop using `||=` if it isn't thread-safe? No.

This stuff is hard because it's unpredictable. You can no longer trace the
execution of the program in a predictable way.

**Any time that you have two or more threads trying to modify the same thing at
the same time, you're going to have issues.** The thread scheduler can interrupt
a thread at *any time.*

How to avoid issues:

1. don't allow concurrent modification
2. protect concurrent modification

**Multi-threaded programming isn't hard.** Sure, it may be difficult, but not
insurmountable. 

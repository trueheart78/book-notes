[&lt;&lt; Back to the README](README.md)

# Chapter 7. How Many Threads Are Too Many?

Concurrency doesn't matter that much if the gains aren't worth it.

So, the answer is **it depends.**

## All the Threads

OS X let's you get about 2k spawned.

Linux can spawn as many as you need without blinking.

## Context Switching

You probably don't want to spawn 10,000 threads on a 4-core CPU.

It does, however, make sense sometimes to spawn more threads than the CPU cores.
It can come down to being IO-bound vs CPU-bound code.

## IO-Bound

Faster network means faster code execution *if* you are hitting remote servers.

Faster HDD means faster code execution *if* you are doing a lot of disk
read/writes.

Spawning more threads than CPU cores makes a lot of sense in these instances.

You should also work on finding a sweet spot for performance. There will be
diminishing returns at one point. Too many threads may adversely affect
performance.

## CPU-Bound

Your code is CPU-bound if its execution is bound by the CPU capabilities of your
machine.

Cryptographic hashes, complex mathematical calculations, etc.

A faster CPU would be able to do these calculations more quickly.

**CPU-bound code is inherently bound by the rate at which the CPU can execute
instructions.** The thread scheduler can incur overhead for extra threads.

**Creating more threads isn't necessarily faster.**

## So... How Many Should You Use?

The only surefire answer is to measure.

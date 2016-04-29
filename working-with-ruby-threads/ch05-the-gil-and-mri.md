[&lt;&lt; Back to the README](README.md)

# Chapter 5. The GIL and MRI

MRI allos concurrent execution of Ruby code, but prevents parallel execution
of Ruby code.

JRuby and Rubinius do not have GIL, and do allow parallel execution of Ruby code.

## The Global Lock

GIL stands for Global Interpreter Lock, also called the GVL (GLobal VM Lock) or
just The Global Lock. All of these mean the same thing.

GIL is a global lock *around the execution of Ruby code.*

There is only one GIL per instance of MRI (or per MRI process). Each MRI process
will have its own GIL.

If one of those MRI processes spawns multiple threads, that group of threads will
share the GIL for that process.

If one of these threads wants to execute some Ruby code, it has to acquire thes
lock. Only one thread can hold said lock. Other threads wait for their turn to
acquire the lock.

**Ruby code will never run in parallel on MRI due to the GIL preventing it.**

An Inside Look at MRI

Each MRI thread is backed by a native thread, and from the kernel's view, they
are all executing in parallel. The GIL is an MRI detail and only comes into play
when executing Ruby code.

The GIL is implemented as a mutex. The OS will guarantee that one and only one
thread can hold the mutex at any time.

When one thread has the GIL, the other threads are put to sleep until it is
released and another thread grabs it.

## The Special Case: Blocking IO

Blocking IO is not Ruby code. So if a thread executes Ruby code that blocks IO,
like visiting a URL, **MRI doesn't let a thread hog the GIL**.

When a thread is blocked waiting for IO, it won't be executin any Ruby code, and
so the GIL gets released.

## Why?

Why would MRI intentionally place a huge restriction on parallel code execution?

The MRI team has, in the past, expressed no intention of getting rid of the GIL.

1. To protect MRI internals from race conditions. It is C code, after all.
2. To facilitate the C extension API. You can interface Ruby with a C library.
3. To reduce the likelihood of race conditions in your Ruby code. **It's a bit
     like wearing full body armor to walk down the street. It helps if you get
     attacked, but most of the time, it's just confining.**

## Misconceptions

The GIL is generally misunderstood.

### Myth: The GIL guarantees your code will be thread-safe.

**This is not true.**

### Myth: The GIL prevents concurreny.

This is a misunderstanding of terms.

The GIL prevents *parallel* execution of Ruby code, not concurrent execution of
Ruby code. Then there is blocking IO, so that you can use threads to parallelize
code that is IO-bound.

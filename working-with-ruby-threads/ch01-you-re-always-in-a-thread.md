[&lt;&lt; Back to the README](README.md)

# Chapter 1. You're Always in a Thread

Ruby is always running in a thread. The main thread you start, say, with `irb`
is the original one created when you start an app. You can start more threads,
but you can't change the reference to `Thread.man`, as it points to this original
thread.

The main thread **terminates all other threads when it exits and ends the Ruby
process**. Only the main thread does this.

`Thread.current` always refers to the current thread. Seems obvious, but since
it can be called from any thread, it always returns the correct thread asking.

If you check the current thread from a new thread, it will not be the main
thread.

```rb
Thread.new { Thread.current == Thread.main }.value
#=> false
```

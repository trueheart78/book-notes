[&lt;&lt; Back to the README](README.md)

# Chapter 12. Processes Are Friendly

## Being CoW Friendly

Using fork(2) to create a new child process that's an exact copy of the parent
process, including everything it has in memory (which can be considerable
overhead), so modern Unix systems employ **copy-on-write** semantics.

CoW delays the actual copying of memory until it needs to be written.

```ruby
arr = [1,2,3]

fork do
  p arr # reads from the same memory location as the parent process
end

arr = [1,2,3

fork do
  arr << 4 # this causes a copy of the array to be made prior to modification
end
```

The above makes fork(2) fast.

Using MRI 2.0.0+ takes advantage of CoW, but earlier versions do not.

## But How?

MRI's garbage collector uses a 'mark-and-sweep' algorithm. The GC must traverse
the graph of live objects, and for each on it must 'mark' it as alive.

In MRI < 2.0, this 'mark' step was implemented as a modification to that object
in memory. So, when GC was invoked right after a `fork`, all live objects were
modified, and foregoing any CoW benefit.

In MRI >= 2.0, the mark-and-sweep GC still exists, but keeps CoW semantics by
storing the 'marks' in a small data structure in a disparate region of memory.
So when the GC runs after a `fork`, this small region of memory must be copied,
but the graph of live Ruby objects can be shared until modified by code.

So if you are building something that depends on fork(2), MRI 2.0+ should give
you better memory utilization than prior versions.

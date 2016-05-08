[&lt;&lt; Back to the README](README.md)

# Chapter 2. Processes Have IDs

Every process running on your system has a unique process ID, a **pid**.

This is how your kernel sees your process: as a number.

Run this in IRB:

```ruby
puts Process.pid
```

A pid is a simple, generic representation of a process. Any programming language
or simple tool can understand it.

## Cross Referencing

o get a full picture, we can use ps(1) to cross-reference our pid with what the
kernel is seeing. While your `irb` session above is open, run the following
command in a terminal:

```sh
ps -p [irb_process_id]
```

## In the Real World

Knowing the pid is very useful if that's all you know.

You will see them in some log files, which is important if you have multiple
processes logging to one file. If you include the pid, you can understand which
logs go together, and trace the thread throughout.

It also allows you to cross reference info with the OS, with tools like top(1)
or lsof(8).

## System Calls

Ruby's `Process.pid` maps to getpid(2).

There is also a global variable that holds the value of the current pid: `$$`

Avoid using `$$` when possible. You are trading off the expressiveness of
`Process.pid`, which is much less likely to confuse a developer.

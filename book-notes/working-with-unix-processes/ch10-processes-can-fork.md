[&lt;&lt; Back to the README](README.md)

# Chapter 10. Processes Can Fork

## Use the fork(2), Luke

Forking is one of the most powerful concepts in Unix programming. The fork(2)
system call allows a running process to create a new process programmatically.
This new process is an exact copy of the original process.

When forking, the process that iniates the fork(2) is called the "parent", and
the newly created process is called the "child".

**The child process inherits a copy of all the memory in use by the parent
process, as well as any open file descriptors belonging to the parent
process.**

Yes, the child process gets its own pid, as well.

In the child, ppid references the parent process that initiated the fork(2).

Multiple processes, due to forking, can share open files, sockets, etc.

Because only one process needs to load the app and forking is fast, forking is
faster than loading the app 3 times in separate instances.

The child process would be free to modify their copy of the memory without
affecting what the parent process has in memory. **Really?**

Here's a fun example:

```ruby
if fork
  puts 'entered the if block'
else
  puts 'entered the else block'
end
```

Outputs:

```
entered the if block
entered the else block
```

One call to the `fork` method actually returns twice. It returns once in the
calling/parent pricess, and once in the new/child process.

With pids:

```ruby
puts "Parent process pid is #{Process.pid}"

if fork
  puts "entered the if block from #{Process.pid}"
else
  puts "entered the else block from #{Process.pid}"
end
```

Outputs:

```
parent process is 21268
entered the if block from 21268
entered the else block from 21282
```

This is down to how `fork` returns values depending on which process it is
currently in. **In the child process `fork` returns `nil`**, and nil is falsy.

**In the parent process `fork` returns the pid of the newly created child
process.**

You can simply print the value of the `fork` call.

```ruby
puts fork
```

outputs:

```
21423
nil
```

## Multicore Programming

Your code would be able (but not be guaranteed) to be distributed across
multiple CPU cores.

fork(2) creates a new process that's a copy of the old process, including the
memory. So forking a 500MB process creates another 500MB process, so you can
easily overwhelm a system. This is called a **fork bomb**.

Before you turn up the concurrency, make sure you know the consequences.

## Using a Block

You can use `fork` to execute code in a block (and only that code).

```ruby
fork do
  puts "awesome child process"
end

puts "lame parent process"
```

## In the Real World

See appendices or Spyglass project to see some real-world examples of using
fork(2).

## System Calls

Ruby's `Kernel#fork` maps to fork(2).

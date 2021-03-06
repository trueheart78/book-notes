[&lt;&lt; Back to the README](README.md)

# Chapter 13. Processes Can Wait

You know how a parent process can exit before a child? It doesn't have to.
If you want fire and forget, it works great, but not for every task.

```ruby
message = 'Good Morning'
recipient = 'josh@example.com'

fork do
  # fork to asynchronously perform some job, like logging data
  # the parent process doesn't care if this is a success or not,
  # and doesn't want to be slowed down by it.
  StatsCollector.record message, recipient
end

# send message to recipient
```

## Babysitting

To babysit, however, `Process.wait` can help.

```ruby
fork do
  5.times do
    sleep 1
    puts "I am an orphan!"
  end
end

Process.wait
abort "Parent process died"
```

The above will cause the fork methods to complete prior to aborting.

Also, control will not be returned to the terminal until the `Process.wait`
is complete.

**`Process.wait` is a blocking call instructing the parent process to wait for
one of its child processes to exit before continuing.**

## Process.wait and Cousins

`Process.wait` returns the pid of the child that exited.

## Communicating with Process.wait2

`Process.wait2`? Yep, because it returns 2 values (pid, status).

The status can be used as a communication between processes via exit codes.

The `status` returned from `Process.wait2` is an instance of `Process::status`.
It provides useful info for how a process exited.

```ruby
5.times do
  fork do
    # generate a random num to exit on a condition
    if rand(5).even?
      exit 111
    else
      exit 112
    end
  end
end

5.times do
  # wait for each of the child processes to exit
  pid, status = Process.wait2

  if status.exitstatus == 111
    puts "#{pid} encountered an even number"
  else
    puts "#{pid} encountered an odd number"
  end
end
```

## Waiting for Specific Children

`Process.waitpid` and `Process.waitpid2`, where you pass a pid for which child
to wait on.

```ruby
favorite = fork do
  exit 77
end

middle_child = fork do
  abort "Wait on me"
end

pit, status = Process.waitpid2 favorite
puts status.exitstatus
```

Don't be fooled: `Process.wait` and `Process.waitpid` are actually aliases, and
accept a pid either way, or a `-1` for them to wait on *any* child process.

## Race Conditions

```ruby
2.times do
  fork do
    abort 'el fin'
  end
end

# parent waits for first process then sleeps
puts Process.wait
sleep 5

# parent process askes to wait once again, but the
# second process' exit info has been queued up and
# returned
puts Process.wait
```

No race conditions in this technique. So even if the parent is slow at
processing each exited child it will always be able to get the info for each
exited child when it's ready for it.

You will see a `Errno::ECHILD` exception occur when you attempt to call any
variant of `Process.wait` when there are no child processes.

## In the Real World

The idea of looking in on your child processes is at the core of a common Unix
programming pattering, sometimes called babysitting processes, master/worker,
or preforking.

The Unicorn web server employs this pattern, whcih allows for both concurrence
and reliability.

## System Calls

Ruby's `Process.wait` and cousins map to waitpid(2).
puts Process.wait

[&lt;&lt; Back to the README](README.md)

# Chapter 15. Processes Can Get Signals

`Process.wait` can be nice, but it is a blocking call: it will not return until
a child process dies.

## Trapping SIGCHLD

Example:

```ruby
child_processes = 3
dead_processes = 3

child_processes.times do
  fork do
    sleep 3
  end
end

# by trapping the :CHLD signal our process will be notified by the kernel when
# one of it's children exits
trap(:CHLD) do
  puts Process.wait
  dead_processes += 1

  exit if dead_processes == child_processes
end

# stay busy
loop do
  (Math.sqrt(rand(44)) ** 8).floor
  sleep 1
end
```

## SIGCHLD and Concurrency

Slight caveat: **Signal delivery is unreliable.** If you are handling a CHLD
signal while another child process dies, *you may or may not receive a second
CHLD signal.*

This can lead to inconsistent results with the above code. This inly happens
when receiving the same signal several times in quick succession.

To properly handle CHLD you must call `Process.wait` in a loop and look for as
many dead child processes as are available.

Thankfully, `Process.wait` takes a second argument, a flag that tells it not to
block.

There is a constant that represents the value of this flag, `Process::WNOHANG`,
and can be used thusly:

```ruby
Process.wait(-1, Process:WNOHANG)
```

Simple.

Now, lets do the above snippet, correctly.

```ruby
child_processes = 3
dead_processes = 3

child_processes.times do
  fork do
    sleep 3
  end
end

# sync $stdout so the call to #puts in the CHLD handler is not buffered.
# do this for handlers that perform IO
$stdout.sync = true

# by trapping the :CHLD signal our process will be notified by the kernel when
# one of it's children exits
trap(:CHLD) do
  begin
    while pid = Process.wait(-1, PROCESS::WNOHANG)
      puts pid
      dead_processes += 1
    end
  rescue Errno:ECHILD
end

loop do
  exit if dead_processes == child_processes
  
  sleep 1
end
```

**Note:** `Process.wait` will raise `Errno::ECHILD` if no child processes
exist. You can have signals arrive at anytime, so it is possible for the last
CHLD signal to arrive after the previous CHLD handler has already called
`Process.wait` twice and gotten the last available status. This can cause
a lot of trouble and be mind bending, as **any line of code can be interrupted
with a signal.**

So you must handle the `Errno::ECHILD` exception in your CHLD signal handler.

## Signals Primer

Signals are asynchronous communication. When a process receives a signal from
the kernel it can do one of:

1. ignore the signal
2. perform a specified action
3. perform the default action

## Where do Signals Come From?

Technically, the kernel. Signals can come from the original process to another
process, using the kernel as a middleman.

The original purpose of signals was to specify different ways a process should
be killed.

Start two `ruby` processes using `irb`.

In the first, do:

```ruby
puts Process.pid
sleep
```

In the second, do:

```ruby
Process.kill(:INT, [pid_of_first_irb])
```

"INT" is short for "INTERRUPT".

The system default when a process receives this signal is that it should
interrupt whatever it is doing and exit immediately.

## The Big Picture

When naming signals the SIG portion of the name is optional. See the
[signal table file](ch15-signal-table.txt) for a rundown.

You can see `SIGUSR1` and `SIGUSR2` are those whose actions are meant to
specifically be defined by your process.

## Redefining Signals

Open two irb processes again.

In the first:

```ruby
puts Process.pid
trap(:INT) { puts "you can't ge tme" }
sleep
```

So the process won't exit now. Let's see

```ruby
Process.kill(:INT, [pid_of_first_irb])
```

Even a Ctrl-C won't kill the first process. To kill it, use:

```ruby
Process.kill(:KILL, [pid_of_first_irb])
```

## Signal Handlers are Global

It's good to keep in mind that **trapping a signal is a bit like using a global
variable.** You could be overwriting something that other code depends on. And
you cannot namespace them.

## Being Nice About Redefining Signals

Use a method similar to this to be nice to other signals:

```ruby
trap(:INT) { puts 'This is the first signal handler' }

old_handler = trap(:INT) {
  old_handler.call
  puts 'this is the second handler'
  exit
}
sleep 5
```

Send it a Ctrl-C and see that both signal handlers are called.

You can't presever the system default behaviour, though.

You shouldn't define any signal handlers unless your code is a server. A
long-running process that is booted from the commandline. Libraries should
rarely trap a signal.

The friendly method of trapping a signal:

```ruby
old_handler = trap(:QUIT) {
  # do some cleanup
  puts 'all done'

  old_handler.call if old_handler.respond_to?(:call)
}
```

While it says friendly, it is not recommended. If you a user sends the QUIT
signal *both* handlers will be invoked.

If you choose to do any of this, make sure you know what you are doing. You
could just use an `at_exit` hook if you simply need to do pre-exit cleanup.

## When Can't You Receive Signals

You can always receive signals.

## In the Real World

Signals are mostly used by long running processes likes ervers and daemons.
And for the most part it will be the human users who are sending signals, not
automated programs.

## System Calls

Ruby's `Process.kill` maps to kill(2), `Kernel#trap` maps roughly to
sigaction(2). signal(7) is also useful.

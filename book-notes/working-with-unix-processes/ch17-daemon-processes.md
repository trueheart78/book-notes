[&lt;&lt; Back to the README](README.md)

# Chapter 17. Daemon Processes

Daemon processes are processes that run in the background, outside of the control
of a user at a terminal. Like a web server, database server, etc.

They are also at the core of your OS. Like the window server on a GUI system, 
audio services, etc.

## The First Process

There is a single daemon process in particular that has significance for your
OS. There is an `init` process that has a ppid of `0` and is the ancestor to
all processors. Its pid is `1`.

## Creating Your First Daemon Process

Any process can be made into a daemon process.

Let's look at the Rack `rackup` command.

## Diving Into Rack

```ruby
def daemonize_app
  if RUBY_VERSION < "1.9"
    exit if fork
    Process.setsid
    exit if fork
    Dir.chdir "/"
    STDIN.reopen "/dev/null"
    STDOUT.reopen "/dev/null, "a"
    STDERR.reopen "/dev/null, "a"
  else
    Process.daemon
  end
end
```

Notice that Ruby 1.9+ ships with a method called `Process.daemon` that will
daemonize the current process.

The C code behind it actually looks a lot like the `if` block above. Support
for daemonizing may not be built into earlier Ruby versions, but it can still
be done.

## Daemonizing a Process, Step by Step

```ruby
exit if fork
```

Remember that `fork` returns twice, once in the parent process, and once in the
child process. So in the parent process, after the fork, the process exits.

This means orpaned processes, but their ppid is always `1`, the pid of the `init`
process.

This makes the process that forked let the user know that it is done with its
job. However, the child carries on.

```ruby
Process.setsid
```

This does 3 things:

1. The process becomes a session leader of a new session
2. The process becomes the process group leader of a new process group
3. The process has no controlling terminal.

## Process Groups and Session Groups

Process groups and session groups are all about job control, meaning the way
that processes are handled by the terminal.

So let's talk process groups.

Each and every process belongs to a group, and each group has a unique integer
id. A process is just a collection fo related processes, typically a parent
process and its children. You can also arbitrarily group them be setting their
group id using `Process.setpgrp(new_group_id)`.

Run this in an irb process:

```ruby
puts Process.getprgrp
puts Process.pid
```

Those two values would be equal, since the process group id will typically be the
same as the pid of the process group leader. It is the originating process of a
terminal command.

Try out this to see that the process groups are inherited:

```ruby
puts Process.pid
puts Process.getpgrp

fork do
  puts Process.pid
  puts Process.getpgrp
end
```

The child process gets a unique pid, but the group id is inherited. These are
part of the same group.

Let's talk orphaned processes again, since child processes are not given special
treatment by the kernel. Exit a parent process and the child will continue on.
When a parent process exits, this happens, but the behaviour when the parent
process is being controlled by a terminal and is killed by signal is different.

Think about a backup script that you Ctl-C out of? It doesn't keep running when
its parent is killed.

The terminal receives the signal and forwards it onto any process in the
foreground process group. In this case, any process that is in the same process
group would be killed by the same signal.

**A session group is one level of abstraction higher up: a collection of
process groups.** Consider this:

```sh
git log | grep shipped | less
```

Each process here will get its own process group, since they aren't children of
each other. Yet, hit Ctrl-C and watch the entire session die.

They are part of the same session group, and each invocation from the shell gets
its own session group. It could be a single command or a chain, as above.

Sessions may be attached to a terminal, or not, in the case of a daemon.

The terminal handles session groups in a special way: sending a signal to the
session leader will forward that signal to all the process groups in that session.
Then those forward it to all the processes in those groups.

To get the current session group id, getsid(2), but Ruby doesn't have a lib for
it. Using `Process.setsid` will return the id of the new session group it creates,
however.

So in the rack code above, the forked process still had inherited the group id
and session id from its parent. That needs to be corrected.

`Process.setsid` will make this forked process the leader of a new process group
and a new session group. Don't try this in a process that is already the group
leader, as that will fail. Only childe processes can execute it.

```ruby
exit if fork
```

The forked process that had become a process group and session group leader forks
again and then exits. This new process isn't a group or a session leader, and
since terminals can only eb assigned to session leaders, it is in the clear.

This means that the process will run to completion, regardless of terminal commands
issued.

```ruby
Dir.chdir "/"
```

Change the current dir to the root dir for the system, ensuring that the current
working dir of the daemon doesn't disappear during its execution.

```ruby
STDIN.reopen "/dev/null"
STDOUT.reopen "/dev/null", "a"
STDERR.reopen "/dev/null", "a"
```

This sets all of the standard streams to go to `/dev/null`, making them ignored.
They are of no use without a terminal session. And they can't just be closed as
some apps expect them to always be available.

## In the Real World

The `rackup` command ships with a command line option for daemonizing the
process. Same goes with any of the popular Ruby web servers.

You should consider looking at the `daemons` rubygem, as well.

Make sure to ask yourself: **Does this process need to stay responsive forever?**

If yes, consider a daemon process. Otherwise, a cron or background job system
should be a better fit.

## System Calls

Ruby's `Process.setsid` maps to setsid(2), `Process.getpgrp` maps to getpgrp(2).

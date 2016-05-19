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



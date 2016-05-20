[&lt;&lt; Back to the README](README.md)

# Chapter 18. Spawning Terminal Processes

A common interaction in a Ruby app is 'shelling out' from your app to run a
command in a terminal.

Before we look at the different ways to 'shell out', let's look at the way
they all work under the hood.

## fork + exec

All of the methods covered are variations on one theme: fork(2) + execve(2).

execve(2) allows you to replace the current process with a different process.

**execve(2) allows you to transform the current process into any other 
process.**

execve(2) transforms the process and never returns.

You can use fork(2) to create a new process, then use execve(2) to transform
that process into anything you like.

If you need output from execve(2) you can use the tools like `Process.wait`
and such.

## File Descriptors and exec

At the OS level, a call to execve(2) doesn't close any open file descriptors.

In Ruby, however, a call to `exec` *will* close all open file descriptors by
default (except the standard ones).

If you `exec('ls')` in the OS, `ls` would get a copy of any open file
descriptors. Ruby doesn't think you need them, so it automatically closes them.

If it did not, you could end up with file descriptor leaks. Other processes
keeping resources alive when they shouldn't be.

You can dictate whether Ruby keeps the file descriptor(s) open by passing an
options hash to `exec` mapping file descriptor numbers to IO objects. Example:

```ruby
hosts = File.open('/etc/hosts')

python_code = %Q[import osl print os.fdopen(#{hosts.fileno}).read()]

# the hash as the last arg maps any file descriptors that should stay open
# through the exec
exec 'python', '-c', python_code, {hosts.fileno: hosts}
```

Notice that `python` recognizes this file descriptor and is able to read from
it without having to re-open the file.

Also notice the options hash mapping the file descriptor number to the `IO`
object. If you remove the hash, the Python program won't be able to open the
file descriptor.

Unlike fork(2), execve(2) **does not share memory** with the newly created
process. The new process gets a blank slate in terms of memory usage.

## Arguments to exec

Pass a string to `exec` and it will start up a shell process and pass the
string to the shell. Pass an array and it will skip the shell and setup the
array directly as the `ARGV` to the new process.

**Generally you want to avoid passing a string unless you really need to.
Pass an array where possible.** It can be a security concern if you pass data
entered by a user.

## Kernel#system

```ruby
system('ls')
system('ls', '--help')
system('git log | tail -10')
```

`Kernel#system` reflects the exit code of the terminal command in the most
basic way. It returns `true` if the exit code was 0, otherwise it returns
`false`.

The standard streams of the terminal command are shared with the current
process, thanks to fork(2), so any output from the terminal command should be
seen in the same way output is seen from the current process.

## Kernel#`

```ruby
`ls`
`ls --help`
%x[git log | tail -10]
```

`Kernel#(backtick)` works slightly different. The value returned is the
`STDOUT` of the terminal program collected into a String.

It is using fork(2) and it doesn't do anything special with `STDERR`, so you
can see that `STDERR` is printed to the screen just as with `Kernel#system`.

`Kernel#(backtick)` and `%x[]` do the exact same thing.

## Process.spawn

```ruby
# this will start up the 'rails server' process with the RAILS_ENV
# environment var set to 'test'
Process.spawn({'RAILS_ENV' => 'test'}, 'rails server')

# this call will merge STDERR with STDOUT for the duration of the 'ls --help'
Process.spawn('ls', '--zz', STDERR => STDOUT)
```

**`Process.spawn` is different as it is non-blocking.**

`Kernel#system` will block until the command is finished but `Process.spawn`
will return immediately.

```ruby
# blocking
system 'sleep 5'

# non-blocking
Process.spawn 'sleep 5'

# Block with Process.spawn
pid = Process.spawn 'sleep 5'
Process.waitpid(pid)
```

Even though we fork(2) and then run the sleep(1) program, the kernel still
knows how to wait for that process to finish.

**All code looks the same to the kernel.**

`Process.spawn` takes many options that allow you to control the behaviour
of the child process. Look up the documentation to see more.

## IO.popen

```ruby
# returns a file descriptor. read from it to return what was printed to
# STDOUT from the shell command.
IO.popen('ls')
```

`IO.popen` is an implementation of Unix pipes in pure Ruby, hence the 'p'.
It is still doing the fork+exec, but also with a pipe being setup with the
spawned process. The pipe is passed as the block arg in the block form of
`IO.popen`.

```ruby
# An IO object is passed into the block. We open it for 'w'riting, so
# it is set to the STDIN of the spawned process
#
# If we open the stream for reading 9the default) then the stream is set
# to the TDOUT of the spawned process.
IO.popen('less', 'w') do |stream|
  stream.puts "some\ndata"
end
```

With `IO.popen` you have to choose which stream you have access to. You can't
access them all at once.

## Open3

`Open3` allows simultaneous access to the STDIN, STDOUT, and STDERR of a
spawned process.

```ruby
# open from the standard lib.
require 'open3'

Open3.popen3('grep', 'data') do |stdin, stdout, stderr|
  stdin.puts "some\ndata"
  stdin.close
  puts stdout.read
end

# Open3 will use Process.spawn when available. Options can be pass to the
# Process.spawn like this:
Open3.popen3('ls', '-uhh', :err => :out) do |stdin, stdout, stderr|
  puts stdout.read
end
```

`Open3` acts like a more flexible version of `IO.popen`, for when you really
need it.

## In the Real World

These are all common methods in the Real World. They all differ slightly, so 
your selection should be based on your needs.

The big drawback is that they all rely on fork(2). If you have a big Ruby app
using a lot of memory, and you shell out with one of these methods, you'll
have to pay the cost of forking.

Even with a simple ls(1) call the kernel will still need to make sure that all
the memory that your Ruby process is using is available for the ls(1) process.
Why? Because of the API of fork(2). Sometimes the cost can create a
performance bottleneck.

For other Unix system calls that can be used for spawning processes without the
overhead of fork(2), but Ruby doesn't have a core language library for them.
Look at the **posix-spawn** project to get access to posix_spawn(2).

`posix-spawn` mimics `Process.spawn`'s API. Most of the options that you can
pass to `Process.spawn` can also be passed to `POSIX::Spawn.spawn`, so you
API usage shouldn't change much.

posix_spawn(2) is a subset of fork(2).

posix_spawn(2) makes sure that the new process gets a copy of all the parent
process' file descriptors, but without an exact copy of everything that the
parent process had in memory.

However, it isn't as flexible as fork(2), but it is more efficient.

## System Calls

`Kernel#system` maps to system(3), `Kernel#exec` maps to execvs(2),
`IO.popen` maps to popen(3), posix--spawn uses posix_spawn(2). Ruby controls
the 'close-on-exec' behavior using fcntl(2) with the `FD_CLOEXEC` option.

[&lt;&lt; Back to the README](README.md)

# Chapter 5. Processes Have Resource Limits

Open resources are represented by file descriptors, and the descriptor numbers
can be ever increasing if the resources aren't closed. So, how many file
descriptors can one prcoess have?

**There are some resource limits imposed on a process by the kernel.**

## Finding the Limits

We can ask directly from within Ruby for the max number of allowed file
descriptors:

```ruby
p Process.getrlimit(:NOFILE)
```

On the author's machine, it outputs:

```
[2560, 9223372036854775807]
```

On the reader's machine, it outputs:

```
[1024, 4096]
```

Using `Process.getrlimit`, we asked for the max number of open files using the
symbol `:NOFILE`, and got back a two-element array.

The first element is the *soft limit*, the second is the *hard limit* for the
number of file descriptors allowed.

## Soft Limits vs. Hard Limits

The *soft limit isn't really a limit*. An exceptio will be raised if you exceed
it, but you can always change that limit if you want to.

On the author's machine, the hard limit is actually infinity
(`Process::RLIM_INFINITY`).

A process could bump the hard limit, if it had the proper permissions. Generally,
it can change its own soft limit, but requires a superuser to change the prior.

## Bumping the Soft Limit

Pretty simple, actually:

```ruby
Process.setrlimit(:NOFILE, 4096)
p Process.getrlimit(:NOFILE)
```

Outputs the following on the author's machine:

```
[4096, 4096]
```

This set a new limit for *both the hard and soft limit.*

A third argument would allow us to specify us to set a new hard limit, as well.
As long as we have permissions, that is.

**Once you lower a hard limit, it is irreversible. You cannot increase it.**

Here is a common way to raise the soft limit of a system resource to be equal
with the current hard limit maximum value:

```ruby
Process.setrlimit(:NOFILE, Process.getrlimit(:NOFILE)[1])
```

## Exceeding the Limit

Exceeding the soft limit will raise `Errno::EMFILE`:

```ruby
Process.setrlimit(:NOFILE, 3)

File.open('/dev/null')
```

Outputs:

```
Errno::EMFILE: Too many open files - /dev/null
```

## Other Resources

You can use thesee same methods to check and modify limits on other system
resources. Common ones include:

+ `:NPROC` for the macimum number of simultaneous processes for the current user
+ `:FSIZE` for the larrgest file size allowed to be created
+ `:STACK` for the max size of the stack segment of the process

See more at the documentation for `Process.getrlimit` online:
[http://www.ruby-doc.org/core-1.9.3/Process.html#method-c-setrlimit](http://www.ruby-doc.org/core-1.9.3/Process.html#method-c-setrlimit )

## In the Real World

Modifying limits for system resources isn't a common need for most programs,
but of course, there are always exceptions for specialized tools.

Using httperf(1) to run performance checks increases the number of allowed
connections if the limit is not large enough. Like `httperf --hog --server www
--num-conn 5000` will ask httperf(1) to create 500 concurrent connections.

Another real world use case would be limiting resources for third-party code,
keeing it within certain restraints.

## System Calls

Ruby's `Process.getrlimit` and `Process.setrlimit` map to getrlimit(2) and
setrlimit(20, respectively.

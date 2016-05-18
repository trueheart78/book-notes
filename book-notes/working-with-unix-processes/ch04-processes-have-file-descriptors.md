[&lt;&lt; Back to the README](README.md)

# Chapter 4. Processes Have File Descriptors

As pids represent running processes, file descriptors represent open files.

## Everything is a File

Part of the Unix philosophy: in the land of Unix, 'everything is a file'.
This means that devices are treated as files, as well as sockets, pipes, and
files.

These will all be termed **resources** going forward. **File** will be used
when talking about classical files.

## Descriptors Represent Resources

Any time you open a resource in a running process it is assigned a file descriptor
number. These are **NOT** shared between unrelated processes, and they live and
die with the process they are bound to, just as any open resoures for a process
are closed when it exits.

In Ruby, open resources are represented by the `IO` class. Any `IO` object can
have an associated file descriptor number. You can access it using `IO#Fileno`:

```ruby
passwd = File.open('/etc/passwd')
puts passwd.fileno
```

outputs:

```sh
3
```

Any resource tht your process opens gets a unique number to ID it. This is how
the kernel keeps track of any resources that your process is using.

Multiple resources:

```ruby
passwd = File.open '/etc/passwd'
puts passwd.fileno

hosts = File.open '/etc/hosts'
puts hosts.fileno

passwd.close #releases the ID

null = File.open '/dev/null'
puts null.fileno
```

outputs:

```sh
3
4
3
```

Two takeways:

1. File descriptor numbers are assigned the lowest unused value.
2. Once a resource is closed its file descriptor number becomes available again.

**File descriptors keep track of open resources only.**

File dscriptors are sometimes called *open file descriptors*. No *closed file
descriptor* exists, so it's a misnomer, of sorts.

```ruby
passwd = File.open '/etc/passwd'
puts passwd.fileno
passwd.close
puts passwd.fileno
```

outputs:

```sh
3
-e:4:in `fileno': closed stream (IOError)
```

## StandardStreams

Every Unix process comes with three open resources. STDIN, STDOUT, and STDERR.

```ruby
puts STDIN.fileno
puts STDOUT.fileno
puts STDERR.fileno
```

outputs:

```sh
0
1
2
```

That's where the first 3 file descriptor IDs went.

## In the Real World

File descriptors are at the core of network programming using sockets, pipes,
etc. and are also at the core of any file system operations.

Hence, they are used by every running process and are at the core of most of
the interesting stuff you can do with a computer.

## System Calls

Many methods on Ruby's `IO` class map to system calls of the same name:

* open(2)
* close(2)
* read(2)
* write(2)
* pipe(2)
* fsync(2)
* stat(2)
* *and many more*

[&lt;&lt; Back to the README](README.md)

# Chapter 16. Processes Can Communicate

How do you communicate information between multiple processes? This is part of
a field of study called Inter-process communication (IPC for short).

Two common ways are **pipes** and **sockets pairs**

## Our First Pipe

A pipe us a uni-directional stream of data. Meaning you can open a pipe, one
process can 'claim' one end of it, and another the other end. Pipe data can
only be passed in one direction, reader or writer.

```ruby
reader, writer = IO.pipe #=> [#<IO:fd 5>, #<IO:fd 6>]
```

`IO.pipe` returns an array with two elements, both of which are `IO` objects.
Ruby's IO class is the superclass to `File`, `TCPSocket`, `UDPSocket`, and 
others.

You can treat the `IO` objects returned like anonymous files. You can `#read`,
`#write`, `#close`, etc. However, it will not respond to `#path` and won't have
a location on the filesystem.

Here's a mult-process pipe example:

```ruby
reader, writer = IO.pipe
writer.write("Into the pipe I go...")
writer.close
puts reader.read
```

Outputs: `Into the pipe I go...`.

Make sure you `#close` relative aspects after you are done with them. `IO#read`
will continue to try reading data until it sees an EOF marker.

So long as the writer is still open the reader might see more data, so it waits.
If you skip closing the writer then the reader will block and try to read forever.

## Pipes Are One-Way Only

```ruby
reader, writer = IO.pipe
reader.write("Trying to get the reader to write something")
```

Outputs:

```sh
 >> reader.write("Trying to get the reader to write something")
IOError: not opened for writing
  from (irb):2:in `write'
  from (irb):2
```

The `IO` objects returned by `IO.pipe` can only be used for uni-directional
communication. The reader can't write and the writer can't read.

## Sharing Pipes

Pipes are considered a resouce, and they get their own file descriptors, etc.
So they are shared with child processes.

```ruby
reader, writer = IO.pipe

fork do
  reader.close

  10.times do
    writer.puts "Another one bites the dust"
  end
end

writer.close
while message = reader.gets
  $stdout.puts message
end
```

This prints out `Another one bites the dust` 10x.

Remember that, since 2 processes are now involved, there are 4 instances floating
around. The reader should be closed at the earliest convenience (in the fork),
and the writer as well (right after the fork).

Notice you can call any `IO` methods on them like `#puts` and `#gets`.

Pipes hold a stream of data.

## Streams vs. Messages

Stream meaning no concept of beginning and end. When working with an IO stream,
like pipes or TCP sockets, you write to the stream followed by some protocol-
specific delimter.

This causes chunking, which is why you read/write one chunk at a time. That's
why `#puts` and `#gets` were used in the last example.

We can communicate via messages instead of streams, but not with pipes. We'll
need Unix sockets to do that. Basically, they are a type of socket that can
only communicate on the same physical machine, and are much faster than TCP
sockets.

Example:

```ruby
require 'socket'
Socket.pair(:UNIX, :DGRAM, 0) #=> [#<Socket:fd 15>, #<Socket:fd 16>]
```

This creates a pair of UNIX sockets that are already connected to each other.
They communicate using datagrams instead of sockets. You write a whole message
to one and read a whole message from the other. No delimiters.

Here's a more complex version:

```ruby
require 'socket'

child_socket, parent_socket = Socket.pair(:UNIX, :DGRAM, 0)
maxlen = 1000

fork do
  parent_socket.close
  4.times do
    instruction = child_socket.recv(maxlen)
    child_socket.send(#{instruction} received!", 0)
  end
end
child_socket.close

2.times do
  parent_socket.send("Heavy lifting", 0)
end
2.times do
  parent_socket.send("Feather lifting", 0)
end

4.times do
  $stdout.puts parent_socket.recv(maxlen)
end
```

Outputs:

```sh
Heavy lifting received!
Heavy lifting received!
Feather lifting received!
Feather lifting received!
```

So pipes provide a one-direction communication, a socket pair provides two-way
communication. A radio vs a set of walkie talkies.

## Remote IPC?

IPC implies communication between processes running on the same machine. If you
want to scale this out, look into TCP sockets, RPC, or ZeroMQ.

## In the Real World

Both pipes and socket pairs are useful for abstractions for process communication.
Fast and easy, too, and no need for a shared database or a log file.

Choose which you want to use based on your needs.

Look at the Spyglass Master appendix to learn more.

## System Calls

Ruby's `IO.pipe` maps to pipe(2), `Socket.pair` maps to socketpair(2).
`Socket.recv` maps to recv(2) and `Socket.send` maps to send(2).

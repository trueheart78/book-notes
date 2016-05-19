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



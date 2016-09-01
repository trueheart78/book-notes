[&lt;&lt; Back to the README](README.md)

# Chapter 12. Multiplexing Connections

Connection multiplexing refers to working with multiple active sockets at the same
time. This is not the same as multi-threading or doing work in parallel.

```ruby
connections = [<TCPSocket>, <TCPSocket>, TCPSocket>]

loop do
  connections.each do |conn|
    begin
      # Attempt to read data from each connection in a non-blocking way
      data = conn.read_nonblock 4096
      process data
    rescue Errno::EAGAIN
    end
  end
end
```

The above works, but it's a very busy loop.

Each call to `read_nonblock` uses at least one system call and the server will be
wasting a lot of cycles trying to read data when there is none. Remember that
`read_nonblock` checks if there us any data available using select(2), and there
is a Ruby wrapper so that we can use select(2) for our own purposes.

## Select(2)

Here's a saner method:

```ruby
connections = [<TCPSocket>, <TCPSocket>, TCPSocket>]

loop do
  # Ask select(2) which connections are ready for reading
  ready = IO.select connections

  # Read data from only the available connections
  readable_connections = ready[0]
  readable_connections.each do |conn|
    data = conn.readpartial 4096
    process data
  end
end
```

This example uses `IO.select` to greatly reduce the overhead of handling multiple
connections. `IO.select` has the goal of taking in some `IO` objects and telling
you which of those are ready to be read from / written to.

### IO.select Review

**It tells you when file descriptors are ready for reading or writing.** In the
above example we only passed a single argument to `IO.select`, but it supports up
to three.

```ruby
for_r = [<TCPSocket>, <TCPSocket>, TCPSocket>]
for_w = [<TCPSocket>, <TCPSocket>, TCPSocket>]

IO.select for_r, for_w, for_r
```

The third argument is for ojects in which you are interested in exceptional
condtions. It comes in handy for out-of-band data (see _Urgent Data_ chapter).

**It accepts arrays, so even a single object must be wrapped in an array.**

**It returns an Array of Arrays.** `IO.select` returns a nested array with three
elements that correspond to its arg list. Each will be a subset of the respective
arrays passed in.

```ruby
for_r = [<TCPSocket>, <TCPSocket>, TCPSocket>]
for_w = [<TCPSocket>, <TCPSocket>, TCPSocket>]

ready = IO.select for_r, for_w, for_r

# One array is returned for each passed in. One of these were ready to be read
# from.
p ready
# => [[<TCPSocket>], [], []]
```

**It is blocking.** `IO.select` is a synchronous method call. Using it like we've
seen thus far will cause it to block until the status of one of the `IO` objects
changes. 

**It takes an optional foruth argument for timeout.** This will prevent
`IO.select` from blocking indefinitely. Pass an int or float to specify a timeout.
It will return `nil` if the timeout is reached.

```ruby
for_r = [<TCPSocket>, <TCPSocket>, TCPSocket>]
for_w = [<TCPSocket>, <TCPSocket>, TCPSocket>]

timeout = 10
ready = IO.select for_r, for_w, for_r, timeout

# In this case the timeout was reached
p ready
# => nil
```

You can also pass plain Ruby objects to `IO.select`, as long as they respond to
`to_io` and return an `IO` object.

## Events Other Than Read/Write

`IO.select` can be shoehorned into a few other places.

### EOF

If you are monitoring a socket for readability and it receives an EOF, it will be
returned as part of the readable sockets Array. Depending on which variant of
read(2) you use at that point, you may get an `EOFError` or `nil` when trying to
read from it.

### Accept

If you're monitoring a server socket for readability and it receives an incoming
connection, it will be returned as part of the readable sockets Array. You will
need to have logic to handle these kinds of sockets specially and use `accept`
rather than `read`.

### Connect

Using `IO.select` we can figure out if the background connect has been completed.

```ruby
require 'socket'

socket = Socket.new :INET, :STREAM
remote_addr = Socket.pack_sockaddr 80, 'google.com'

begin
  socket.connect_nonblock remote_addr
rescue Errno::EINPROGRESS
  IO.select nil, [socket]

  begin
    socket.connect_nonblock remote_addr
  rescue Errno::EISCONN
    # Success!
  rescue Errno::ECONNREFUSED
    # Refused by remote host
  end
end
```

Try to do a `connect_nonblock` and `rescue Errno::EINPROGRESS`, which signifies
that the connect is happening in the background. Then we can enter the new code.

Receiving a `Errno::EISCONN` exception means that we're already connected. That's
a good thing.

This fancy code actually emulates a _blocking_ connect. Why? To show what is
possible.

We can actually use this technique to build a simple port scanner.

```ruby
require 'socket'

PORT_RANG = 1..128
HOST = 'archive.org'
TIME_TO_WAIT = 5

sockets = PORT_RANGE.map do |port|
  socket = Socket.new :INET, :STREAM
  remote_addr = Socket.sockaddr_in port, HOST

  begin
    socket.connect_nonblock remote_addr
  rescue Errno::EINPROGRESS
  end

  socket
end

expiration = Time.now + TIME_TO_WAIT

loop do
  _, writable, _ = IO.select nil, sockets, nil, expiration - Time.now
  break unless writable

  writable.each do |socket|
    begin
      socket.connect_nonblock socket.remote_address
    rescue Errno::EISCONN
      # Success
      puts "#{HOST}:#{socket.remote_address.ip_port} acceptions connections"
      # Remove the socket
      sockets.delete socket
    rescue Errno::EINVAL
      sockets.delete socket
    end
  end
end
```

This initiates several hundred connections at once, and then monitors them using
`IO.select` and then reports on those that were able to be connected to.

## High Performance Multiplexing

`IO.select` ships with Ruby's stdlib. It works well with a few connections, but
its performance is linear to the number of connections it monitors. It will also
be limited to monitoring something called the `FD_SETSIZE`, a C macro that's
defined as part your local C library, which is generally defined as 1024. So no
more than 1024 `IO` object can be monitored using `IO.select`.

There is poll(2), epoll(2), or (in BSD) kqueue(2). A high-performance networking
toolkit like EventMachine will favour epoll(2) or kqueue(2) where possible.

Rather than trying to give examples, look at the
[nio4r Ruby gem](https://github.com/tarcieri/nio4r), which provides a common
interface to all of the multiplexing solutions, favouring whichever the most
performant available on your system.

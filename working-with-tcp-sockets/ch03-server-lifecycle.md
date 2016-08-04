[&lt;&lt; Back to the README](README.md)

# Chapter 3. Server Lifecycle

A server socket listens for connections rather than initiating them. The typical
lifecycle looks something like this:

1. create
2. bind
3. listen
4. accept
5. close

The first has been covered earler, now for the rest.

## Servers Bind

You **bind** to a port where you will listen for connections.

```ruby
require 'socket'

# new TCP socket
socket = Socket.new :INET, :STREAM

# need a struct to hold the address to listen to
addr = Socket.pack_sockaddr_in 4481, '0.0.0.0'

# bind them together
socket.bind addr
```

The above is a low-level implementation that shows how to bind a TCP socket to
a local port.

Keep in mind the code currently only binds, and doesn't yet listen, so it will
run and exit once done.

**A server binds to a specific, agreed-upon port number which a client socket
can then connect to.**

### What Port Should I Bind To?

So many questions revolve around this, so here is some simple advice:

1. **Don't use a port in the 0-1024 range.** These are reserved for system use.
2. **Don't use a port in the 49,000-65,535 range.** These are the ephemeral
   ports , typically used by services that don't operate on a predefined port
   but need ports for temporary purposes.

So **any port from 1,025-48,999 is fair game for your uses.** Be sure to check
[Iana.org](https://www.iana.org) and make sure your choice doesn't conflict with
another popular server out there.

### What Address Should I Bind To?

The above example binds to `0.0.0.0`, but that's a different interface than
`127.0.0.1`. The loopback interface is on the latter, so it only listens on the
specific IP address. If you bind on `192.168.0.5`, that's the only interface
that will be listened to.

You can use `0.0.0.0` if you want to listen on *all* interfaces, loopback, or
otherwise.

```ruby
require 'socket'

# bind to localhost only
local_socket = Socket.new :INET, :STREAM
local_addr = Socket.pack_sockaddr_in 4481, '127.0.0.1'
local_socket.bind local_addr

# bind to all interfaces
any_socket = Socket.new :INET, :STREAM
any_addr = Socket.pack_sockaddr_in 4481, '0.0.0.0'
any_socket.bind any_addr

# unknown interface - raises Errno::EADDRNOTAVAIL
error_socket = Socket.new :INET, :STREAM
error_addr = Socket.pack_sockaddr_in 4481, '1.2.3.4'
error_socket.bind error_addr
```

## Servers Listen

After creating a socket and binding to a port, then it needs to be told to
listen for incoming connections.

```ruby
require 'socket'

socket = Socket.new :INET, :STREAM
addr = Socket.pack_sockaddr_in 4481, '0.0.0.0'
socket.bind addr

# listen for incoming connections
socket.listen 5
```

At the end, we call `listen`, but the code still exits immediately. We'll get
to that in a minute.

### The Listen Queue

Passing an integer to the `listen` method defines the max number of pending
connections your server socket is willing to tolerate. This is called **the
listen queue**.

If the listen queue fills up while waiting on responses, the client will raise
`Errno::ECONNREFUSED`.

### How Big Should the Listen Queue Be?

Keep limites in mind. The currently allowed max listen queue size can be checked
by calling `Socket::SOMAXCONN` at runtime, and should be around 128. To increase
this, you need to be a root user to increase the system level setting.

If you are getting reports of `Errno::ECONNREFUSED`, you can increase the num
allowed, but keep in mind that will use more bandwidth, as well as the resources
required to process the connection's defined workload. You may need more
servers.

Generally, you don't want to be refusing connections, so it is a good idea to
set the max queue allowed size using `server.listen Socket::SOMAXCONN`.

## Servers Accept

This is where we talk about handling an *incoming* connection. It does this with
the `accept` method.

```ruby
require 'scoket'

server = Socket.new :INET, :STREAM
addr = Socket.pack_sockaddr_in 4481, '0.0.0.0'
server.bind addr
server.listen Socket::SOMAXCONN

# accept a connection
connection, _ = server.accept
```

You should notice that the code *does not return immediately*, as the `accept`
method will block until a connection arrives. We can pass one via the command
line.

```sh
echo ohai | nc localhost 4481
```

### Accept is Blocking

The `accept` call is a blocking call, meaning that it will block the current
thread indefinitely until it receives a new connection.

Remember the listen queue we talked about in the last chapter? `accept` simply
pops the next pending connection off of that queue. It waits for on to be pushed
on if none are available.

### Accept Returns an Array

Notice that the above call assigns two values from one call to `accept`. The
`accept` method actually returns an Array. The first element returned is the
connection, and the second is an `Addrinfo` object, which represents the remote
address of the client connection

## Addrinfo

`Addrinfo` is a ruby class that represents a host and port num. It wraps up an
endpoint representation nicely, and you'll see it around.

You can construct one of these using `Addrinfo.tcp 'localhost', 4481`. It has
`#ip_address` and `#ip_port` methods. You can view the docs by running
`ri Addrinfo` in the command line.

Here's a closer look.

```ruby
require 'socket'

# Create the server socket
server = Socket.new :INET, :STREAM
addr = Socket.pack_addrinfo_in 4481, '0.0.0.0'
server.bind addr
server.listen Socket::SOMAXCONN

# Accept a new connection
connection, _ = server.accept

print 'Connection class: '
p connection.class

print 'Server fileno: '
p server.fileno

print 'Connection fileno: '
p connection.fileno

print 'Local address: '
p connection.lcaol_address

print 'Remote address: '
p connection.remote_address
```

If you send another connection using `echo hello | nc localhost 4481`, you will
see something akin to the following:

```
Connection class: Socket
Server fileno: 5
Connection fileno: 98
Local address: #<Addrinfo: 127.0.0.1:4481 TCP>
Remote address: #<Addrinfo: 127.0.0.1:58164 TCP>
```

This set of results tell us a ton about how TCP connections are handled.

## Connection Class

A connection is actually just an instance of `Socket`.

## File Descriptors

We know that `accept` is returning an instance of `Socket`, but this conn has
different file descriptor number (or `fileno`) than the server socket. The file
descriptor number is the kernel's method for keeping track of open files in the
current process.

### Sockets are Files?

Yes, in the land of Unix, everything is treated as a file (files, pipes,
sockets, printers, etc.)

This indicates that `accept` has returned a brand new `Socket` different from
the server socket. This `Socket` instance represents the conn, which is very
important. Each conn is represented by a new `Socket` so the server socket can
remain untouched and continue to accept new conns.

## Connection Addresses

Our conn object knows about two addresses: the local and the remote. The remote
address is the second return value from `accept`, but can also be accessed as
`#remote_address` on the conn.

The `local_address` of the conn refres to the endpoint on the local machine. The
`remote_address` of the conn refers to the endpoint at the other end, whether it
be on another host or not.

Each TCP conn is defined by this unique grouping of local-host, local-port,
remote-host, and remote-port. The combination of these four properties **must**
be unique for each TCP connection.

## The Accept Loop

So `accept` returns one connection, and in our example, it exits immediately.
You can setup a loop so that it does not exit immediately after the first conn
is processed.

```ruby
require 'socket'

# Create the server socket
server = Socket.new :INET, :STREAM
addr = Socket.pack_addrinfo_in 4481, '0.0.0.0'
server.bind addr
server.listen Socket::SOMAXCONN

# Enter an endless loop of accepting and handling connections.
loop do
  connection, _ = server.accept
  # handle connection
  connection.close
end
```

The above is a common way to write certain kinds of servers using Ruby. It's so
common in fact that Ruby provides some syntactic sugar on top of it. We'll get
to that later in this chapter.

## Servers Close

Once a server has accepted a conn and finished processing it, the last thing for
it to do is to `close` that connection, rounding out the create-process-close
lifecycle of a conn. You can see that in the above code example.

### Closing on Exit

Why is `close` needed? When your program exists, all open file descriptors (that
includes sockets) will be closed for you. Closing them yourself is a good habit:

1. Resource usage. Releasing resources tied to references no longer needed means
   not depending on the garbage collector to clean up after everything.
2. Open file limit. Every process is subject to a limit on the number of files
   it can have. Keeping around unneeded connections will continue to bring your
   process closer and closer to this open file limit, which may cause issues
   later.

To find out the number of allowed open files for the current process, use
`Process.getrlimit :NOFILE`. The returned Array is the soft-limit (user setable)
nad hard limit (system restricted), respectively.

If you want to bump up your limit to the max, use
`Process.setrlimit(Process.getrlimit(:NOFILE)[1])`

## Different Kinds of Closing

Given that sockets allow two-communication (read/write) it's actually possible
to close just one of those channels.

```ruby
require 'socket'

# Create the server socket
server = Socket.new :INET, :STREAM
addr = Socket.pack_addrinfo_in 4481, '0.0.0.0'
server.bind addr
server.listen Socket::SOMAXCONN

# After this, the conn may no longer write data, but may still receive
connection.close_write

# After this, the conn may no longer read or write any data
connection.close_read
```

Closing the write stream will send an `EOF` to the client.

The `close_write` and `close_read` methods make use of shutdown(2) under the
hood, which is different that close(2) in that it causes a part of the conn
to be fully shut down, even if there are copies of it lying around.

### How Are There Copies of Connections?

From `Socket#dup` to `Process.fork`, it can occur. And it is common.

`close` will close the socket instance on which it is called.

`shutdown` will fully shut down any communication on the current socket **and**
other copies of it, disabling any communication happening on every instance. It
does not, however, reclaim resources used by the socket. They still need to have
`close` sent to them to complete the lifecycle.

```ruby
require 'socket'

# Create the server socket
server = Socket.new :INET, :STREAM
addr = Socket.pack_addrinfo_in 4481, '0.0.0.0'
server.bind addr
server.listen Socket::SOMAXCONN

# Create a copy of the connection
copy = connection.dup

# Shut down all communication to the connection
connection.shutdown

# Close the original connection. The copy will be closed when the GC collects it
connection.close
```

## Ruby Wrappers

Ruby can take care of a lot of the code we keep having to repeat. Compare
the following method of creating a new TCP-based listener:

```ruby
require 'socket'

server = TCPServer.new 4481
```

Much more succint! Keep in mind that this returns a `TCPServer` instance, not a
`Socket` instance. The most notable difference is that `TCPServer#accept`
returns only the conn, not the remote address.

Also, note we didn't specify the size of the listen queue? Ruby defaults that to
a size of 5. You can increase it by calling `TCPServer#listen` after the fact.

You can also create TCP sockets to listen on both IPv4 and IPv6.

```ruby
require 'socket'

servers = Socket.tcp_server_sockets 4481
```

#### Connection Handling

Ruby doesn't need th `loop` construct, instead it works like this:

```ruby
require 'socket'

server = TCPServer.new 4481

# Enters an endless loop of accepting and handling connections
Socket.accept_loop(server) do |connection|
  # handle connection
  connection.close
end
```

Do note the the connections are not automatically closed at the end of each
block.

`Socket.accept_loop` has the added benefit that you can actually pass multiple
listening sockets to it and it will accept connections on *any of the passed-in
sockets.* This goes quite welll with `Socket.tcp_server_sockets`:

```ruby
require 'socket'

servers = Socket.tcp_server_sockets 4481

Socket.accept_loop(servers) do |connection|
  # handle connection
  connection.close
end
```

We can pass in all the servers at once :heart:

### Wrapping It All Into One

Ruby makes it simple using `Socket.tcp_server_loop`, wrapping all the previous
steps into one:

```ruby
require 'socket'

Socket.tcp_server_loop(4481) do |connection|
  # handle connection
  connection.close
end
```

This method is really just a wrapper around the code we wrote before it, but it
makes our development lives much easier.

## System Calls From This Chapter

* Socket#bind -> bind(2)
* Socket#listen -> listen(2)
* Socket#accept -> accept(2)
* Socket#local_address -> getsockname(2)
* Socket#remote_address -> getpeername(2)
* Socket#close -> close(2)
* Socket#close_write -> shutdown(2)
* Socket#shutdown -> shutdown(2)

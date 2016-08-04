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

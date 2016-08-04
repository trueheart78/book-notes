[&lt;&lt; Back to the README](README.md)

# Chapter 4. Client Lifecycle

The client takes the role of initiating the connections with the server and
creates an outbound connection to it.

The client lifecycle is

1. create
2. bind
3. connect
4. close

Step 1 is the same for both.

## Clients Bind

Client sockets begin life in the same way as servers sockets, with `bind`. In
the server section we called `bind` with a specific address and port. It is rare
for a server to not call `#bind`, but **it is rare for a client to call bind.**
If the client socket (or server, for that matter) omit the call to bind, it will
get assigned a random port from the ephemeral range.

### Why Not Call Bind?

Because clients don't need to be accessible from a known port number.

Clients don't call `bind` because no one needs to know what their port number
is.

## Clients Connect

What really separates a client from a server is the call to `connect`.

```ruby
require 'socket'

socket = Socket.new :INET, :STREAM

# Initiate a connection to google.com on port 80
remote_addr = Socket.pack_sockaddr_in 80, 'google.com'
socket.connect remote_addr
```

#### Connect Gone Awry

A client can potentially connect to a server before it is ready to accept conns,
as well as attempt to connect to non-existent servers. These both have the same
outcome. TCP is optimistic, so it waits as long as it can for a response.

Let's try connecting to a non-existent endpoint:

```ruby
require 'socket'

socket = Socket.new :INET, :STREAM

# Initiate a connection to google.com on port 70
remote_addr = Socket.pack_sockaddr_in 70, 'google.com'
socket.connect remote_addr
```

If the connection is waited out, you'll eventually see an `Errno::ETIMEDOUT`
exception raised. There's an entire chapter later down the road: 
[Chapter 15. Timeouts](ch15-timeouts.md)

The same behavior is observed when a client connects to a server that has
called `bind` and `listen` but not yet called `accept`.

## Ruby Wrappers

### Client Construction

```ruby
require 'socket'

socket = TCPSocket.new 'google.com', 80
```

There is also a block form :+1:

```ruby
require 'socket'

Socket/tcp('google.com', 80) do |connection|
  connection.write "GET / HTTP/1.1\r\n"
  connection.close
end

# Omitting the block argument behaves the same as TCPSocket.new
client = Socket.tcp 'google.com', 80
```

## System Calls From This Chapter

* Socket#bind -> bind(2)
* Socket#connect -> connect(2)

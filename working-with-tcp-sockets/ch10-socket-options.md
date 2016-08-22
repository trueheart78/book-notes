[&lt;&lt; Back to the README](README.md)

# Chapter 10. Socket Options

Socket options are low-level ways to configure system specific behaviors on
sockets. So low-level that Ruby doesn't provide a fancy wrapper around the
system calls.

## SO_TYPE

Let's see how to retrieve a socket option: the socket type.

```ruby
require 'socket'

socket = TCPSocket.new 'google.com', 80
# get an instance of Socket::Option that represents the type
opt = socket.getsockopt Socket::SOL_SOCKET, Socket::SO_TYPE

# compare the int representation of the option to the int store in the
# Socket::SOCK_STREAM for comparison
opt.int == Socket::SOCK_STREAM
# => true
opt.int == Socket::SOCK_DGRAM
# => false
```

A call to `getsockopt` returns an instance of `Socket::Option`. When working at
this level, everything resloves to integers. So `SocketOption#int` gets the
underlying integer associated with the return value.

Remember that Ruby **always** offers memoized symbols in place of these
constants. The above can also be written as:

```ruby
require 'socket'

socket = TCPSocket.new 'google.com', 80
# Use the symbol names rather than constants
opt = socket.getsockopt :SOCKET, :TYPE
```

## SO_REUSE_ADDR

This is a common option that **every** server should set.

The `SO_REUSE_ADDR` option tells te kernel that it's OK for another socket to
bind to the same local address that the server is using, **if it's currently
in the TCP TIME_WAIT state**

### TIME_WAIT State?

This can come about when you `close` a scoket that has pending data in its
buffers. Remember calling `write` only guarantees that you data has entered the
buffer layers? When you `close` a socket its pending data is **not** discarded.

Behind the scenes, the kernel leaves the connection open long enough to send
out that pending data. This means that it actually has to send the data, and
then wait for acknowledgement of receipt from the receiving end in case some
data needs retransmitting.

If you close a server with pending data and immediately try to `bind` another
socket on the same address (such as if you reboot the server immediately) then
an `Errno::EADDRINUSE` will be raised unless the pending data has been accounted
for. So setting `SO_REUSE_ADDR` will circumvent this problem and allow you to
`bind` to an address still in use by another socket in the `TIME_WAIT` state.

Here's how:

```ruby
require 'socket'

server = TCPServer.new 'localhost', 4481
server.setsockopt :SOCKET, :REUSEADDR, true

server.getsockopt :SOCKET, :REUSEADDR
# => true
```

Note that `TCPServer.new`, `Socket.tcp_server_loop`, and other friends, enable
this option by default.

## System Calls From This Chapter

* `Socket#setsockopt` -> setsockopt(2)
* `Socket#getsockopt` -> getsockopt(2)

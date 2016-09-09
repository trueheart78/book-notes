[&lt;&lt; Back to the README](README.md)

# Chapter 13. Nagle's Algorithm

Nagle's algorithm is a so-called optimization applied to all TCP connections by
default.

This optimization is most applicable to apps which don't do buffering and send
very small amounds of data at a time. It's often disabled by servers where those
criteria don't apply.

After a program writes to a socket there are three possible outcomes:

1. If there is sufficient data in the local buffers to comprise an entire TCP
   packet then send it all immediately.
1. If there is no pending data in the local buffers and no pending
   acknowledgement of rreceipt from the receiving end, then send it immediately.
1. If there is a pending acknowledgement of receipt from the other end and not
   enough data to comprise an entire TCP packet, then put the data into the local
   buffer.

This algorithm guards against sending many tiny TCP packets, and was originally
designed to combadt protocols like telnet where one keystroke is entered at a
time, which would means they could be sent across the network without delay.

If you are working with a protocol like HTTP where the request/response are
usually large enough to comprise at least one TCP packet, this algorithm will
typically have no effect except to slow down the last packet sent. It is meant
to guard against shooting yourself in the foot during very specific situations,
such as implementing a telnet. Given Ruby's buffering and the most common kinds
of protocols implemented on TCP, you probably want to disable this algorithm.

Every Ruby web server disables this option. Here's how.

```ruby
require 'socket'

server = TCPServer.new 4481
# Disable Nagle's algorithm and tell the server to send without delay.
server.setsockopt Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1
```

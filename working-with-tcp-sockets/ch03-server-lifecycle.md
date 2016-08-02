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



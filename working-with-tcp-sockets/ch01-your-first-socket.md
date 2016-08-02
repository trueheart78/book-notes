[&lt;&lt; Back to the README](README.md)

# Chapter 1. Your First Socket

## Ruby's Socket Library

Part of the Ruby standard library.

`require 'socket'`

## Creating Your First Socket

```ruby
require 'socket'

socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
```

This creates a socket of type `STREAM` in the `INET` domain (short for
internet), and refers to an IPv4 socket.

The `STREAM` part says you'll be communicating using a stream, which is
provided by TCP. You could have said `DGRAM` (for datagram) instead of `STREAM`
and that would refer to a UDP socket. The type tells the kernel what kind of
socket to create.

## Understanding Endpoints

Sockets use I{ addresses to route messages to specific hosts.

### The IP Address Phone Book

DNS is a system that maps host names to IP addresses, so you don't have to
remember the specific address of the host.

## Loopbacks

IP addresses can also refer to your localhost.

Most systems define a loopback interface, a virtual interface and is not
attached to any hardware. Any data sent to the loopback interface is immediately
received on the same interface. This constrains your network to the local host.

Typically a loopback interface is called `localhost` and has an IP of
`127.0.0.1`.

## IPv6

IPv6 is an alternate addressing scheme for IP addresses, and supports more
unique host addresses.

## Ports

The port number is the phone number _extension_ of a socket endpoint.

The combo of IP and port must be unique for each socket.

### Which Port Number Should I Use?

This problem is not solved with DNS, but with a list of well-defined port nums.

[Iana.org](https://www.iana.org) actually maintains this list.

## Creating Your Second Socket

Time for some Ruby flavor. `Socket::AF_INET` can be represented by `:INET`, and
`Socket::SOCK_STREAM` by `:STREAM`.

```ruby
require 'socket'

socket = Socket.new(:INET, :STREAM)
```

## Docs

Great places to find documentation:

1. Unix Man Pages are extremely helpful, and section 2 is generally where we
   look for information. So socket(2) refers to `man 2 socket`, the socket man
   page in section 2.
2. `ri` is Ruby's command-line doc tool. `ri Socket.new` should bring up the
   docs for `Socket`.

## System Calls From This Chapter

- Socket.new -> socket(2)

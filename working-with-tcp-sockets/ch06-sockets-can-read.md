[&lt;&lt; Back to the README](README.md)

# Chapter 6. Sockets Can Read

## Simple Reads

```ruby
require 'socket'

Socket.tcp_server_loop(4481) do |conn|
  # simplest read from the connection
  puts conn.read

# let's the client know they can stop waiting for a response
  conn.close
end
```

Ruby's various socket classes, along with `File`, share a common parent: `IO`.
All IO objects in Ruby share a common public interface with methods like `read`,
`write`, `flush`, etc.

Remember, **everything is a file.**

## It's Never That Simple

The ability to read data may seem simple, but the above code is actually quite
brittle. Run the following against this server and leave it alone, and you will
see that the server will never finish reading the data, and therefore, never
exit.

```sh
tail -f /var/log/system.log | nc localhost 4481
```

This comes down to the EOF (end-of-file). We'll deal with that shortly.

The gist of the issue is that `tail -f` never finishes sending data, so it waits
and keeps the connection open. It's being piped to `netcat` and so it, too,
waits indefinitely.

The server's call to `read` will continue blocking until the client finishes
sending data. 

## Read Length

One way to skirt the above iss is to specify a minimum length to be read.

```ruby
require 'socket'
one_kb = 1_024

Socket.tcp_server_loop(4481) do |conn|
  while data = connection.read(one_kb) do
    puts data
  end

  conn.close
end
```

Run the above with the same command as before:

```sh
tail -f /var/log/system.log | nc localhost 4481
```

We defined the minimum chunk to process, and the connection would only read
data when the passed-in size specified was met.

## Blocking Nature

A call to `read` will always want to block and wait for the full length of data
to arrive. The above code will see `read` block until one full kilobyte can be
read.

You can get into deadlock due to this.

You can fix it in two ways:

1. The client sends an EOF after sending the smaller-than-required amount of
   data.
2. The server uses a partial read.

## The EOF Event

When a connection is being `read` from and receives an EOF event, it can be sure
that no more data will be coming over the conn and it can stop reading. This is
super important, concept-wise, for an IO operation.

If everything is a file, then everything can have an end-of-file (EOF).

You may see reference to an *EOF character* or *EOF marker*, but that's not the
true form. EOF is not a character sequence, **EOF is more like a state event.**
When a socket has no more data to write, it can `shutdown` or `close` its
ability to write any more data. This results in an EOF event being sent to the
reader on the other end, letting it know that no more data will be snet.

A remedy for this situation would be for the client to send their 500 bytes,
then send an EOF event.

**Server:**

```ruby
require 'socket'
one_kb = 1_024

Socket.tcp_server_loop(4481) do |conn|
  while data = connection.read(one_kb) do
    puts data
  end

  conn.close
end
```

**Client:**

```ruby
require 'socket'
TCPSocket.new(localhost', 4481).write('hola').close
```

The simplest way for a client to send an EOF is to close its socket.

A quick reminder that EOF is aptly named. When you call `File#read` it behaves
just like `Socket#read`. It will read data until it's all consumed. Once that
happens, it receives an EOF event and returns the data it has.

## Partial Reads

Calls to `readpartial`, rather than wanting to block, want to return available
data immediately. When calling `readpartial` you also tell it the maximum length
to read. It will not block if less than that maximum length is received.

```ruby
require 'scoket'
one_hundred_kb = 1_024 * 100

Socket.tcp_server_loop(4481) do |conn|
  begin
    # Read data in chunks of 100 kb or less
    while data = conn.readpartial(one_hundred_kb) do
      puts data
    end
  rescue EOFError
  end

  conn.close
end
```

Communicate with this command:

```sh
tail -f /var/log/system.log | nc localhost 4481
```

This will show the server is streaming each bit of data as it becomes
accessible, rather than waiting for 100 kb of data. `readpartial` will happily
return less than its max length if the data is available.

In terms of EOF, `readpartial` raises an `EOFError` instead of of just returning
like `read`. 

`read` is lazy, and `readpartial` is eager.

## System Calls From This Chapter

* `Socket#read` -> read(2), behaves more like fread(3).
* `Socket#readpartial` -> read(2).


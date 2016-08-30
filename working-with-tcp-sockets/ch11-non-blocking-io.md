[&lt;&lt; Back to the README](README.md)

# Chapter 11. Non-Blocking IO

Non-blocking IO is different from asynchronous or evented IO. You'll learn about
the differences throughout the rest of the book.


## Non-Blocking Reads

When we looked at `read` a few chapters back, it was noted that it blocked until
it received EOF or was able to receive a minimum number of bytes. This may result
in a lot of blocking when a client doesn't send EOF. This blocking behaviour can
be partly circumvented by `readpartial`, which returns any available data
immediately. However, it will still block if there is no data available. For a
`read` operation that will _never_ block, you want `read_nonblock`.

`read_nonblock` requires an integer specifying the max number of bytes to read.
It may return less than the max amount of bytes, if that's what is available.

```ruby
require 'socket'

Socket.tcp_server_loop(4481) do |conn|
  loop do
    begin
      puts conn.read_nonblock(4096)
    rescue Errno::EAGAIN
      retry
    rescue EOFError
      break
    end
  end

  conn.close
end
```

Boot up the same client we used previously that never closes its connection:

```sh
tail -f /var/log/system.log | nc localhost 4481
```

Even where there is no data being sent to the server the call to `read_nonblock` 
is still returning immediately. In fact, it's raising an `Errno::EAGAIN`
exception. That means the file was marked for non-blocking I/O, but no data was
ready to be read. In this instance, `readpartial` would have just blocked.

The proper way to retry a blocked read is using `IO.select`

```ruby
begin
  conn.read_nonblock(4096)
rescue Errno::EAGAIN
  IO.select [conn]
  retry
end
```

This achieves the same effect as spamming `read_nonblock` with `retry`, but with
less wasted cycles. Calling `IO.select` with an array of sockets as the first arg
will block until one of the sockets becomes available. So `retry` will only be
called when the socket has data available for reading.

In this example, a blocking `read` method has been re-implemented using
non-blocking methods. Not very useful, but using `IO.select` gives the flexibility
to monitor multiple sockets at the same time, or periodically check for
readability while doing other work.

### When Would a Read Block?

The `read_nonblock` method first checks Ruby's internal buffers for any pending
data. If there is some, it's immediately returned.

It then asks the kernel if there is any data available for reading using
select(2). If the kernel says there is some data available, that data is consumed
and returned. Any other condition would cause a read(2) to block and raise an
exception from `read_nonblock`.

## Non-Blocking Writes

Non-blocking writes have some very important differences from the `write` call we
saw earlier. The most notable is that it is possible for `write_nonblock` to
return a partial write, whereas `write` will always take care of writing all of
the data that you send it.

Let's see this behaviour with a throwaway server.

```sh
nc -l localhost 4481
```

Then we'll boot up this client that makes use of `write_nonblock`:

```ruby
require 'socket'

client = TCPSocket.new 'localhost', 4481
payload = 'Chunky Bacon' * 10_000

written = client.write_nonblock payload
written < payload.size
# => true
```

When I run those two programs against each other, I routinely see `true` being
printed out from the client-side. In other words, it is returning an int that is
less than the full size of the payload data. The `write_nonblock` method returned
because it entered a situation where it would block, so it didn't write anymore
data and returned an int, letting us know how much was written. It is our
responsibility to write the rest of the unsent data.

The behaviour of `write_nonblock` is the same as the write(2) system call. It
writes as much data as it can and returns the number of bytes written. This
differs from Ruby's `write` method which may call write(2) several times to write
all the data requested.



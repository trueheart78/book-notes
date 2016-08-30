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



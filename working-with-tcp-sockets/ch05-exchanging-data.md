[&lt;&lt; Back to the README](README.md)

# Chapter 5. Exchanging Data

Connections are all good and fine, but are useless without passing data.

## Streams

**TCP is a stream-based protocol.** If we didn't set the `:STREAM` option, it
technically would not be a TCP socket.

A TCP connection provides an ordered stream of communication with no beginning
and now end. There is only the stream.

```ruby
# sends data over the network, 3 times, one at time 
%w(a b c).each do { |piece| write_to_connection piece }

# consumes those three pieces of data in one operation
result = read_from_connection #=> ['a', 'b', 'c']
```

**Stream has no concept of message boundaries.** Even when the client sent
multiple pieces of data, the server received them as a chunk.

Do notice that the order was preserved, even if the chunks themselves were
conglomerated.

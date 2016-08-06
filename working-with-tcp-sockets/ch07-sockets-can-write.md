[&lt;&lt; Back to the README](README.md)

# Chapter 7. Sockets Can Write

Writing to sockets really only uses the `write` method.

```ruby
require 'socket'

Socket.tcp_server_loop(4481) do |conn|
  conn.write 'Welcome'
  conn.close
end
```

That's it, no hidden magic.

## System Calls From This Chapter

* `Socket#write` -> write(2)

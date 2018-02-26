[&lt;&lt; Back to the README](README.md)

# Chapter 9. Our First Client/Server

## The Server

A NoSQL solution that uses a network layer on top of a Ruby hash. It's called:
`CloudHash`.

```ruby
require 'socket'

module CloudHash
  class Server
    def initialize(port)
      @server = TCPServer.new port
      puts "Listening on port #{@server.local_address.ip_port}"
      @storage = {}
    end

    def start
      Socket.accept_loop(@server) do |conn|
        handle conn
        conn.close
      end
    end

    def handle(conn)
      request = conn.read
      conn.write process(request)
    end

    # supported commands:
    # SET key value
    # GET key
    def process(request)
      icommand, key, value = request.split

      case command.upcase
      when 'GET'
        @storage[key]

      when 'SET'
        @storage[key] - value
      end
    end
  end
end
```

CloudHash::Server.new(4481).start

## The Client

```ruby
require 'socket'

module CLoudHash
  class Client
    class << self
      attr_accessor :host, :port
    end

    def self.get(key)
      request "GET #{key}"
    end

    def self.set(key, value)
      request "SET #{key} #{value}"
    end

    def self.request(string)
      @client = TCPSocket.new(host, port)
      @client.write string

      # send EOF after writing the request
      @cient.close_write

      i# read until EOF to get the response
      @client.read
    end
  end
end
```

## Putting It All Together

Boot the server:

```sh
ruby cloud_hash/server.rb
```

Rememer the data structure is a Hash. Running the client will run the following
operations:

```sh
tail -4 cloud_hash/client.rb
puts CloudHash::Client.set 'prez', 'obama'
puts CloudHash::Client.get 'prez'
puts CloudHash::Client.get 'vp'

ruby cloud_hash/client.rb
```

## Thoughts

We wrapped the getter and setter of a hash with a network API.

It certainly is not optimized yet, however.

**CloudHash, as it stands, does not provide a good example of how socket
programming should be done.**

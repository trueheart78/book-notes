[🔙 Cancellation][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Race Conditions 🔜][upcoming-chapter]

# Chapter 68. Example: Chat Server

Let's wrap up talk on C with a chat server. There are four kinds of Gs in this app. One instance
of `main` and `broadcaster` Gs, and for each client connection there is a `handleConn` and
`clientWriter` G. The broadcaster is a good illustration of how `select` is used, since it has to
respond to three different kinds of messages.

The job of the main G is to listen for and accept incoming network connections from clients.
For each one, it creates a new `handleConn` G, just as in the concurrent echo server we saw early
in the C chapters.

```go
// gopl.io/ch8/chat
func main() {
    listener, err := net.Listen("tcp", "localhost:8000")
    if err != nil {
        log.Fatal(err)
    }

    go broadcaster()
    for {
        conn, err := listener.Accept()
        if err != nil {
            log.Print(err)
            continue
        }
        go handleConn(conn)
    }
}
```

Next is the broadcaster. Its local var `clients` records the current set of connected clients. The
only info recorded about each client is the identity of its outgoing message C.

```go
type client chan<- string // an outgoing message channel

var (
    entering = make(chan client)
    leaving  = make(chan client)
    messages = make(chan string) // all incoming client messages
)

func broadcaster() {
    clients := make(map[client]bool) // all connected clients
    for {
        select {
        case msg := <-messages:
            // Broadcast incoming message to all
            // clients' outgoing message channels.
            for cli := range clients {
                cli <- msg
            }
        
        case cli := <-entering:
            clients[cli] = true

        case cli := <-leaving:
            delete(clients, cli)
            close(cli)
        }
    }
}
```

The broadcaster listens on the global `entering` and `leaving` Cs for announcements of arriving
and departing clients. When it receives one of these events, it updates the `clients` set, and if
the event was a departure, it closes the client's outgoing message C. The broadcaster also listens
for events on the global `messages` C, to which each client sends all its incoming messages. When
the broadcaster receives one of these events, it broadcasts the message to every connected client.

Now let's look at the per-client Gs. The `handleConn` fn creates a new outgoing message C for its
client and announces the arrival of the client to the broadcaster over the `entering` C. Then it
reads every line of text from the client, sending each to the broadcaster over the global incoming
message C, prefixing each message with the identity of its sender. Once there is nother more to
read from the client, `handleConn` announces the departure of the client over the `leaving` C and
closes the connection.

```go
func handleConn(conn net.Conn) {
    ch := make(chan string) // outgoing client messages
    go clientWriter(conn, ch)

    who := conn.RemoteAddr().String()
    ch <- "You are " + who
    messages <- who + " has arrived"
    entering <- ch

    input := bufio.NewScanner(conn)
    for input.Scan() {
        messages <- who + ": " + input.Text()
    }
    // NOTE: ignoring potential errors from input.Err()

    leaving <- ch
    messages <- who + " has left"
    conn.Close()
}

func clientWriter(conn net.Conn, ch <-chan string) {
    for msg := range ch {
        fmt.Fprintln(conn, msg) // NOTE: ignoring network errors
    }
}
```

In addition, `handleConn` creates a `clientWriter` G for each client that receives messages
broadcast to the client's outgoing message C and writes them to the client's network connection.
The client writer's loop terminates when the broadcaster closes the C after receiving a `leaving`
notification.

The display below shows the server in action with two clients in separate windows on the same
computer, using `netcat` to chat:

```
$ go build gopl.io/ch8/chat
$ go build gopl.io/ch8/netcat3
$ ./chat &
$ ./netcat3
You are 127.0.0.1:64208               $ ./netcat3
127.0.0.1:64211 has arrived           You are 127.0.0.1:64211
Hi!
127.0.0.1:64208: Hi!                  127.0.0.1:64208: Hi!
                                      Hi yourself.
127.0.0.1:64211: Hi yourself.         127.0.0.1:64211: Hi yourself.
^C
                                      127.0.0.1:64208 has left
$ ./netcat3
You are 127.0.0.1:64216               127.0.0.1:64216 has arrived
                                      Welcome.
127.0.0.1:64211: Welcome.             127.0.0.1:64211: Welcome.
                                      ^C
127.0.0.1:64211 has left
```

While hosting a chat session for _n_ clients, this runs _2n+2_ concurrently communicating Gs, yet
it needs no explicit locking ops. The `clients` map is confined to a single G so it doesn't need to
worry about external access. The only vars that are shared by multiple Gs are Cs and instances of
`net.Conn`, both of which are _concurrency safe_. Confinement, concurrency safety, and the
implications of shared vars is the topic of the next set of chapters.

## Exercises

* Make the broadcaster announce the current set of clients to each new arrival. This requires that
the `clients` set and the `entering` and `leaving` Cs record the client name, too.
* Make the chat server disconnect idle clients (after 5 minutes, maybe?). Hint: Calling 
`conn.Close()` in another G unblocks active `Read` calls like the one done by `input.Scan()`.
* Change the chat server's network protocol so that each client provides a name on entering. Use
that instead of the network address when chatting.
* Failure of any client app to read data in a timely manner causes a lock. Modify the broadcaster 
to skip a message rather than wait if a client writer is not ready to accept it. Alternatively,
add buffering to each client's outgoing message C so that most messages are not dropped; the
broadcaster should use a non-blocking send to this C.

[🔙 Cancellation][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Race Conditions 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch067-cancellation.md
[upcoming-chapter]: ch069-race-conditions.md

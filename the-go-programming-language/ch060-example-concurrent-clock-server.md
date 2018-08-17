[🔙 Goroutines][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Example: Concurrent Echo Server 🔜][upcoming-chapter]

# Chapter 60. Example: Concurrent Clock Server

Networking is a natural domain in which to use concurrency since servers typically handle many conns
from clients at one time, each being independent of the others. So we'll be using the `net` pkg to 
provide components for building networked client and server apps that chat over TCP, UDP or Unix
domain sockets.

Here's a sequential clock server that writes the current time to the client once per second:

```go
// gopl.io/ch8/clock1
// Clock1 is a TCP server that periodically writes the time.
package main

import (
    "io"
    "log"
    "net"
    "time"
)

func main() {
    listener, err := net.Listen("tcp", "localhost:8000")
    if err != nil {
        log.Fatal(err)
    }
    for {
        conn, err := listener.Accept()
        if err != nil {
            log.Print(err) // e.g., connection aborted
            continue
        }
        handleConn(conn) // handle one connection at a time
    }
}

func handleConn(c net.Conn) {
    defer c.Close()
    for {
        _, err := io.WriteString(c, time.Now().Format("15:04:05\n"))
        if err != nil {
            return // e.g., client disconnected
        }
        time.Sleep(1 * time.Second)
    }
}
```

The `Listen` fn creates a `net.Listener`, an object that listens for incoming conns on a network
port, in this case, TCP port `localhost:8000`. The listener's `Accept` method blocks until an
incoming conn request is made, and then it returns a `net.Conn` object.

The `handleConn` fn handles one complete client connection. In a loop, it writes the current time,
`time.Now()`, to the client. 

Using netcat, we can make a connection for this:

```
$ go build gopl.io/ch8/clock1
$ ./clock1 &
$ nc localhost 8000
13:58:54
13:58:55
13:58:56
13:58:57
^C
```

You can see that its once per second. If you try and run a second `nc` call it will be blocked and
receive no data. **That's not good.** We can fix the current implementation by adding the `go`
keyword before the `handleConn` call.

```go
// gopl.io/ch8/clock2
for {
    conn, err := listener.Accept()
    if err != nil {
        log.Print(err) // e.g., connection aborted
        continue
    }
    go handleConn(conn) // handle connections concurrently
}
```

Now, multiple clients can receive the time at once.

```
$ go build gopl.io/ch8/clock2
$ ./clock2 &
$ go build gopl.io/ch8/netcat1
$ ./netcat1
14:02:54                               $ ./netcat1
14:02:55                               14:02:55
14:02:56                               14:02:56
14:02:57                               ^C
14:02:58
14:02:59                               $ ./netcat1
14:03:00                               14:03:00
14:03:01                               14:03:01
^C                                     14:03:02
                                       ^C
$ killall clock2
```

## Exercises

**8.1:** Modify `clock2` to accept a port number, and write a program, `clockwall`, that acts
as a client of several clock servers at once, reading the times from each one and displaying the 
results in a table, akin to the wall of clocks seen in some business offices. If you have access 
to geographically distributed computers, run instances remotely; otherwise run local instances on 
different ports with fake time zones.

```
$ TZ=US/Eastern    ./clock2 -port 8010 &
$ TZ=Asia/Tokyo    ./clock2 -port 8020 &
$ TZ=Europe/London ./clock2 -port 8030 &
$ clockwall NewYork=localhost:8010 London=localhost:8020 Tokyo=localhost:8030
```

**8.2:** Implement a concurrent File Transfer Protocol (FTP) server. The server should interpret 
commands from each client such as `cd` to change directory, `ls` to list a directory, `get` to send 
the contents of a file, and `close` to close the connection. You can use the standard `ftp` command 
as the client, or write your own.

[🔙 Goroutines][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Example: Concurrent Echo Server 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch059-goroutines.md
[upcoming-chapter]: ch061-example-concurrent-echo-server.md

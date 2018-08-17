[🔙 Example: Concurrent Clock Server][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Channels 🔜][upcoming-chapter]

# Chapter 61. Example: Concurrent Echo Server

The clock server used one G per Conn. Here, we'll build an echo server that uses multiple Gs per
Conn. Most echo servers merely write whatever they read, whcih can be done quite trivial:

```go
func handleConn(c net.Conn) {
    io.Copy(c, c) // NOTE: ignoring errors
    c.Close()
}
```

A more interesting server might simulate the reverb of a real echo, with the response loud at first,
and then moderate, and finally, quiet.

```go
// gopl.io/ch8/reverb1
func echo(c net.Conn, shout string, delay time.Duration) {
    fmt.Fprintln(c, "\t", strings.ToUpper(shout))
    time.Sleep(delay)
    fmt.Fprintln(c, "\t", shout)
    time.Sleep(delay)
    fmt.Fprintln(c, "\t", strings.ToLower(shout))
}

func handleConn(c net.Conn) {
    input := bufio.NewScanner(c)
    for input.Scan() {
        echo(c, input.Text(), 1*time.Second)
    }
    // NOTE: ignoring potential errors from input.Err()
    c.Close()
}
```

We'll need to upgrade our client app so it sends terminal input to the server while also copying
the server response to the output, which presents another opportunity to use concurrency.

```go
// gopl.io/ch8/netcat2
func main() {
    conn, err := net.Dial("tcp", "localhost:8000")
    if err != nil {
        log.Fatal(err)
    }
    defer conn.Close()
    go mustCopy(os.Stdout, conn)
    mustCopy(conn, os.Stdin)
}
```

While the main G reads the std input and sends it to the server, a second G reads and prints the
servers response. When the main G encounters the end of the input, for example, after the user types
ctrl-D at the terminal, the app stops, even if the other G still has work to do.

```
$ go build gopl.io/ch8/reverb1
$ ./reverb1 &
$ go build gopl.io/ch8/netcat2
$ ./netcat2
Hello?
    HELLO?
    Hello?
    hello?
Is there anybody there?
    IS THERE ANYBODY THERE?
Yooo-hooo!
    Is there anybody there?
    is there anybody there?
    YOOO-HOOO!
    Yooo-hooo!
    yooo-hooo!
^D
$ killall reverb1
```

Notice that the third shout from the client is not dealt with until the second shout has petered out.
Let's fix that with another G, as it should be a _composition_ of the three independent shouts.

```go
// gopl.io/ch8/reverb2
func handleConn(c net.Conn) {
    input := bufio.NewScanner(c)
    for input.Scan() {
        go echo(c, input.Text(), 1*time.Second)
    }
    // NOTE: ignoring potential errors from input.Err()
    c.Close()
}
```

The args to the fn started by `go` are evaluated when the `go` statement is executed; thus 
`input.Text()` is eval'd in the main G.

```
$ go build gopl.io/ch8/reverb2
$ ./reverb2 &
$ ./netcat2
Is there anybody there?
    IS THERE ANYBODY THERE?

Yooo-hooo!
    Is there anybody there?
    YOOO-HOOO!
    is there anybody there?
    Yooo-hooo!
    yooo-hooo!
^D
$ killall reverb2
```

ALl that was required to make the server use concurrency, not just to handle conns from multiple
clients but even within a single conn, was the insertion of two `go` keywords.

However, in adding them, we had to consider carefully that it is safe to call methods of `net.Conn`
concurrently, which isn't true for all types. That's up next.

[🔙 Example: Concurrent Clock Server][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Channels 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch060-example-concurrent-clock-server.md
[upcoming-chapter]: ch062-channels.md

[🔙 A Few Words of Advice][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Example: Concurrent Clock Server 🔜][upcoming-chapter]

# Chapter 59. Goroutines

In Go, each concurrently executing activity is called a _goroutine_ (G). Consider an app that has two
fns, one that does some computation and one that writes some output, and that neither calls the
other. A sequential app may call one fn and then the other, but in a _concurrent_ app with two or
more G, calls to _both_ fns can be active at the same time.

This can be similar to OS threads or threads in other languages.

When an app starts, its only G is the one that calls the `main` fn, so we call it the 
_main goroutine_. New G are created by the `go` statement. Syntactically, a `go` statement is an
ordinary fn or method call prefixed by the keyword `go`. This causes the fn to be called in a newly
created G. The `go` statement itself completes immediately.

```go
f()    // call f(); wait for it to return
go f() // create a new goroutine that calls f(); don't wait
```

In the next example, the main G computes the 45th Fibonacci number. It will use an ineffecient
recursive algorithm, it runs for a bit, and during this time, we'd love a spinner to show for the
user.

```go
func main() {
    go spinner(100 * time.Millisecond)
    const n = 45
    fibN := fib(n) // slow
    fmt.Printf("\rFibonacci(%d) = %d\n", n, fibN)
}

func spinner(delay time.Duration) {
    for {
        for _, r := range `-\|/` {
            fmt.Printf("\r%c", r)
            time.Sleep(delay)
        }
    }
}

func fib(x int) int {
    if x < 2 {
        return x
    }
    return fib(x-1) + fib(x-2)
}
```

After several seconds of animation, the `fib(45)` call returns and the `main` fn returns. When this
happens, all G are terminated and the app exits. Other than by returning from main or exiting the app
there is no programmatice way for one G to stop another. There are ways to communicate between Gs,
however.

[🔙 A Few Words of Advice][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Example: Concurrent Clock Server 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch058-a-few-words-of-advice.md
[upcoming-chapter]: ch060-example-concurrent-clock-server.md

[🔙 Looping in Parallel][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Multiplexing with select 🔜][upcoming-chapter]

# Chapter 64. Example: Concurrent Web Crawler

Let's update the earlier [web crawler][web crawler] usage to be concurrent.

```go
// gopl.io/ch8/crawl1
func crawl(url string) []string {
    fmt.Println(url)
    list, err := links.Extract(url)
    if err != nil {
        log.Print(err)
    }
    return list
}
```

Now, a worklist records the queue of items that need processing, each item being a list of URLs to
crawl, but instead of using a `slice`, we're going to use a C. Each call to `crawl` occurs in its own
G and sends the links it discovers back to the worklist:

```go
func main() {
    worklist := make(chan []string)

    // Start with the command-line arguments.
    go func() { worklist <- os.Args[1:] }()

    // Crawl the web concurrently.
    seen := make(map[string]bool)
    for list := range worklist {
        for _, link := range list {
            if !seen[link] {
                seen[link] = true
                go func(link string) {
                    worklist <- crawl(link)
                }(link)
            }
        }
    }
}
```

Notice that the nested G takes the `link` as a param, as we've seen before, to avoid concurrency
issues. Also, notice that the initial send of the CLI args to the `worklist` must run in its own G
to avoid _deadlock_, a stuck situation in which both the main G and a crawler G attempt to send to
each other while neither is receiving. You could also use a bC here.

Now we have a highly concurrent crawler that prints a storm or URLs, but it also has two problems.
The first manifests itself as error messages in the log after a few seconds of operation:

```
$ go build gopl.io/ch8/crawl1
$ ./crawl1 http://gopl.io/
http://gopl.io/
https://golang.org/help/

https://golang.org/doc/
https://golang.org/blog/
...
2015/07/15 18:22:12 Get ...: dial tcp: lookup blog.golang.org: no such host
2015/07/15 18:22:12 Get ...: dial tcp 23.21.222.120:443: socket:
                                                        too many open files
...
```

The initial error message is a surprising report of a DNS lookup failure on a reliable domain. After
that, however, you see the message that reveals the cause: too many network connections at once that
it exceeded the per-process limit on the number of open files, causing ops such as DNS lookups and
`net.Dial` to start failing.

Yes, the issue is that _the program is too parallel_. Unbounded parallelism is rarely a good idea
since there is always a limiting factor in the system, like CPU cores, spindles and heads on disks,
bandwidth of the network, or even serving capacity of a web server. Our solution reqiures limiting
the number of parallel uses of the resource to match the level of parallelism that is available.
A simple way to do that in our example is to ensure that no more than _n_ calls to `links.Extract`
are active at once, where _n_ is comfortably less than the file descriptor limit - let's say 20.

We can limit parallelism using a bC of capacity _n_ to model a concurrency primitive called a
_counting semaphore_. Conceptually, each of the _n_ vacant slots in the C buffer represents a token
entitling the holder to proceed. Sending a value into the C acquires a token, and receiving a val
from the C releases a token, creating a new vacant slot. This ensures that at most _n_ sends can
occur without an intervening receive. Since the C type is not important, we'll use `struct{}`, which
has size zero.

So let's change the `crawl` fn so that the call to `links.Extract` is bracketed by ops to acquire
and release a token, ensuring that at most 20 calls to it are active at once. It's good practice to
keep the semaphore ops close to the I/O op they requlate.

```go
// gopl.io/ch8/crawl2
// tokens is a counting semaphore used to
// enforce a limit of 20 concurrent requests.
var tokens = make(chan struct{}, 20)

func crawl(url string) []string {
    fmt.Println(url)
    tokens <- struct{}{} // acquire a token
    list, err := links.Extract(url)
    <-tokens // release the token

    if err != nil {
        log.Print(err)
    }
    return list
}
```

The second problem is that the app never terminates, even when all the links have been discovered. So
we should break out of the main loop when the worklist is empty _and_ no crawl Gs are active.

```go
func main() {
    worklist := make(chan []string)
    var n int // number of pending sends to worklist

    // Start with the command-line arguments.
    n++
    go func() { worklist <- os.Args[1:] }()

    // Crawl the web concurrently.
    seen := make(map[string]bool)
    for ; n > 0; n-- {
        list := <-worklist
        for _, link := range list {
            if !seen[link] {
                seen[link] = true
                n++
                go func(link string) {
                    worklist <- crawl(link)
                }(link)
            }
        }
    }
}
```

In this version, the counter `n` keeps track of sends to the worklist that are yet to occur. Each
time we know an items needs to be sent to the worklist, we increment `n`, once before the CLI args
are snagged, and again each time we start a crawler G. The main loop terminates when `n` falls to
zero, since no more work is necessary.

Now the concurrent crawler runs about 20 times faster than the breadth-firsth crawler from earlier,
sans errors, and terminates correctly if it completes its task.

We can also look at an alternative solution to the problem of excessive concurrency. It uses the
original `crawl` fn sans semphore, but calls it from one of 20 long-lived crawler Gs, keeping the
limit in place.

```go
// gopl.io/ch8/crawl3
func main() {
    worklist := make(chan []string)  // lists of URLs, may have duplicates
    unseenLinks := make(chan string) // de-duplicated URLs

    // Add command-line arguments to worklist.
    go func() { worklist <- os.Args[1:] }()

    // Create 20 crawler goroutines to fetch each unseen link.
    for i := 0; i < 20; i++ {
      go func() {
            for link := range unseenLinks {
                foundLinks := crawl(link)
                go func() { worklist <- foundLinks }()
            }
        }()
    }

    // The main goroutine de-duplicates worklist items
    // and sends the unseen ones to the crawlers.
    seen := make(map[string]bool)
    for list := range worklist {
        for _, link := range list {
            if !seen[link] {
                seen[link] = true
                unseenLinks <- link
            }
        }
    }
}
```

The crawler Gs are all fed by `unseenLinks` C. The main G is responsible for de-duping links, and
sending new ones over the `unseenLinks` C to a crawler G.

The `seen` map is _confined_ within the main G. Links found by `crawl` are sent to the worklist from
a dedicated G to avoid deadlock.

To save space, we left out how to terminate in this example.

[🔙 Looping in Parallel][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Multiplexing with select 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch063-looping-in-parallel.md
[upcoming-chapter]: ch065-multiplexing-with-select.md
[web crawler]: https://github.com/adonovan/gopl.io/tree/master/ch5/findlinks3

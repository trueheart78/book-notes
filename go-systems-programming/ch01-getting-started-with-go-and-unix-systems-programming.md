[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Writing Programs in Go 🔜][upcoming-chapter]

# Chapter 1. Getting Started with Go and Unix Systems Programming

## What is Systems Programming?

* File I/O
* Advanced file I/O
* System files and config
* Files and dirs
* Process control
* Threads
* Server processes
* Interprocess communication
* Signal processing
* Network programming

## Two Useful Go Tools

* `gofmt`: auto-formats the code we write. Vim even has a plugin to do this on save, along with
linting.
* `godoc`: `godoc -http=:8080` will put create a webserver you can access on `localhost:8080`.
You can also do `go doc fmt.Println` to get quick and handy output.

```
func Println(a ...interface{}) (n int, err error)
    Println formats using the default formats for its operands and writes to
    standard output. Spaces are always added between operands and a newline is
    appended. It returns the number of bytes written and any write error
    encountered.
```

[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Writing Programs in Go 🔜][upcoming-chapter]

[readme]: README.md
[upcoming-chapter]: ch02-writing-programs-in-go.md

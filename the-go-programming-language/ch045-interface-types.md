[🔙 Interfaces as Contracts][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Interface Satisfaction 🔜][upcoming-chapter]

# Chapter 45. Interface Types

_Notes_
An interface type specifies a set of methods that a concrete type must posses to be considered an
instance of that interface. The `io.Writer` type is one of many `io` interfaces. A `Reader` 
represents any type from which you can read bytes, and a `Closer` is any value that you can close,
like a file or net connection.

```go
package io

type Reader interface {
  Read(p []byte) {n int, err error}
}

type Closer interface {
  Close() error
}
```

A littler further on, we see combinations. Yes, that is a thing 💖

```go
type ReaderWriter interface {
  Reader
  Writer
}

type ReaderWriterCloser interface {
  Reader
  Writer
  Closer
}
```

The syntax used (akin to struct embedding) lets us name another interface as a shorthand for writing
out all of its methods. We call this _embedding_ an interface.

[🔙 Interfaces as Contracts][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Interface Satisfaction 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch044-interfaces-as-contracts.md
[upcoming-chapter]: ch046-interface-satisfaction.md

[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[A Glorified Calculator 🔜][upcoming-chapter]

# Chapter 1. Get Ready, Get Set, Go

Go is the contemporary programming language of cloud computing. It's being adopted
for serious projects, especially in the infrastructure that underpins the web.

Go is designed for the modern data center, but it isn't restricted to enterprise uses.

The community of people who have adopted Go call themselves _gophers_, in honor of Go's
light-hearded mascot. Programming should be fun, even if it is challenging.

![Go mascot][go-mascot]

## What is Go?

Go is a _compiled_ language. Before you run a program, the code has to be translated
into machine code. 

> We wanted a language with the safety and performance of statically compiled
> languages such as C++ and Java, but the lightness and fun of dynamically typed
> interpreted languages such as Python. - [Rob Pike Geek of the Week][rob-pike]

Go is crafted witha  gread deal of consideration for the _experience_ of writing
software. Large programs compile quickly, and the language omits features that can
lead to ambiquity, encouraging code that os predictable and easy to understand.
It is even a lightweight alternative to the rigid structure imposed by languages
like Java.

> Java omits many rarely used, poorly understood, confusing features of C++ that,
> in our experience, bring more grief than benefit - James Gosling from "Java: an
> Overview"

Each new language refines ideas of the past. Go makes it easier and less error-prone
to use memory efficiently, and to take advantage of every core on multi-core machines.
Success stories often cite improved efficiency as a reason for switching to Go.
Iron.io has scaled server requirements down [from 30 running Ruby to 2 using Go][30-servers]
and has been using [Go in production for over 4 years][go-4-it]. [Moving from Python
to Go][bitly] has had "consistent, measurable performance gains" for Bit.ly. They
have even replaced their C apps with a Go successor.

If you want a compiled language in your tool belt, Go provides the enjoyment and
ease of interpreted languages, with a step up in efficiency and reliability. Don't
be too surprised, it's [in the motto][motto].

> Go is an open source programming language that makes it easy to build simple,
> reliable, and efficient software.

### 💡 Tip

When searching the internet for topics related to Go, use the keyword `golang`.

## The Go Playground

The quickest way to get started with Go is to navigate to [play.golang.org][playground].

This will enable you to edit, run, and experiment with Go code without needing to
install anything.

## Packages and Functions

The following code is shown when visiting the [playground][playground].

```go
// declare the package this code belongs to
package main

// make the format package available for use
import "fmt"

// declare a function named main
func main() {
  // print to the screen
	fmt.Println("Hello, playground")
}
```

Short but with some keywords worth understanding: `package`, `import`, and `func`.

`package` declares the package this code belongs to. All code in Go is organized
into _packages_. Go provides a standard library comprised of packages for math,
compression, cryptography, image manuplation, etc. Each pertain to a single idea.

`import` specifies a package that the code will use.

`func` declares a function, this one named `main`. The body of each function is
contained in curly braces.

Main is special. When you run a program in Go, execution begins at the `main`
function in the `main` package.

To print a line of text, you can use the `Println` function. Since it's part of
the `fmt` package, it gets called via `fmt.Println`.

## The One True Brace Style

The opening brace is on the same line as the `func` keyword, and the closing brace
is on its own line. This traces back to semicolons being part of a the code, and
the expulsion of that need instead made this the requirement. It's a trade-off
worth making.

[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[A Glorified Calculator 🔜][upcoming-chapter]

[readme]: README.md
[upcoming-chapter]: ch02-a-glorified-calculator.md
[go-mascot]: images/go-mascot.png
[rob-pike]: https://www.red-gate.com/simple-talk/opinion/geek-of-the-week/rob-pike-geek-of-the-week/
[30-servers]: https://blog.iron.io/how-we-went-from-30-servers-to-2-go/
[go-4-it]: https://www.infoq.com/presentations/go-iron-production
[bitly]: http://word.bitly.com/post/29550171827/go-go-gadget
[motto]: https://golang.org/
[playground]: https://play.golang.org/

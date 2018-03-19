[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Understanding Goroutines 🔜][upcoming-chapter]

# Chapter 1. Development Environment for Go

## `go get`

`go get` is the utility provided by the std lib for pkg management. We can install
a new plg/lib by running the following command:

```
go get git-server.com/user-name/library-we-need
```

This will download and build the source code and then install it as a binary
executable (if it can be used as a standalone executable). The go get utility
also installs all the dependencies required by the dependency retrieved for our
project.

## `dep`

The Go dependency management tool, `dep`, is the official experiment, but not
yet the official tool. Requires Go 1.9 or newer. See the [dep repo][dep] for
more details on installation and usage.

Default installation method on MacOS is via Homebrew

```
brew install dep
brew upgrade dep
```

On non-MacOS systems, you can use the `curl` command.

```
curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
```

## Containers

We try to use **containers** for solving the OS-level virtualization.

All programs and applications are run in a section of memory known as **user space**.
This allows the OS to ensure a program is not able to cause major hardware or
software issues, and enables recovery from any program crashes that may occur.

The _real_ advantage of containers is that they allow us to run applications in
isolated user spaces, and we can even customize the following attributes of user
spaces:

* Connected devices such as network adapters and TTY
* CPU and RAM resources
* Files and folders accessible from host OS

### Understanding Docker

The following list and related image should help understand the Docker pipeline:

* **Dockerfile**: It consists of instructions on how to build an image that runs our program.
* **Docker client**: This is a cli used by the user to interact with the Docker daemon.
* **Docker daemon**: This is the Daemon app that listens for commands to manage building or running
containers to a Docker registry. It is also responsible for configuring container networks, volumes, etc.
* **Docker images**: Docker images contain all the required steps to build a container binary that can
be executed on any Linux machine with Docker installed.
* **Docker registry**: This is responsible for storing and retrieving Docker images. We can use a public
or private Docker registry. Docker Hub is used as the default Docker registry.
* **Docker Container**: A Docker container is a runnable instance of a Docker image. It can be created,
started, stopped, etc.
* **Docker API**: The Docker client discussed above is a cli to interact with the Docker API. The
default setup that we will be using talks to the Docker daemon on the local system using UNIX sockets
or a network interface:

![docker arch][docker-arch]

### Testing Docker

Install the [Docker Community Edition][docker-community] and then run a few basic commands to verify
it is setup properly.

```
$ docker --version
Docker version 17.12.0-ce, build c97c6d6
```

```
$ docker info
Containers: 38
 Running: 0
 Paused: 0
 Stopped: 38
Images: 24
Server Version: 17.12.0-ce
```

Once this is all working, run the following:

```
docker run docker/whalesay cowsay Welcome to GopherLand!
```

You can also do the above like this:

```
docker pull docker/whalesay & docker run docker/whalesay cowsay Welcome to GopherLand!
```

To see what images we've downloaded, we can list them with `docker images`

Finally, we can remove "dangling" images (that we may not use again).

```
$ docker rmi --force 'docker images -q -f dangling=true'
# list of hashes for all deleted images.
```

### Dockerfile

Now that we've got the basics down, let's look at the template for the `Dockerfile` we'll be using.

Example:

```docker
FROM golang:1.10
# The base image we want to use to build our docker image from. 
# Since this image is specialized for golang it will have GOPATH = /go                

ADD . /go/src/hello
# We copy files & folders from our system onto the docker image                       

RUN go install hello 
# Next we can create an executable binary for our project with the command,
# 'go install'

ENV NAME Bob
# Environment variable NAME will be picked up by the program 'hello' 
# and printed to console.

ENTRYPOINT /go/bin/hello
# Command to execute when we start the container  
 
# EXPOSE 9000 
# Generally used for network applications. Allows us to connect to the
# application running inside the container from host system's localhost.
```

#### `main.go`

Let's try out the `Dockerfile`, referencing an evnironment variable in our app.

Create a new `docker` project in your `GOPATH`.

```go
package main 
 
import ( 
    "fmt" 
    "os" 
) 
 
func main() { 
    fmt.Println(os.Getenv("NAME") + " is your uncle.") 
}
```

Now let's try and execute it.

```
$ cd docker
$ tree
.
├── Dockerfile
└── main.go"
0 directories, 2 files 
 
$ # -t tag lets us name our docker images so that we can easily refer to them 
 
$ docker build . -t hello-uncle  
Sending build context to Docker daemon 3.072 kB 
Step 1/5 : FROM golang:1.9.1 
 ---> 99e596fc807e 
Step 2/5 : ADD . /go/src/hello 
 ---> Using cache 
 ---> 64d080d7eb39 
Step 3/5 : RUN go install hello 
 ---> Using cache 
 ---> 13bd4a1f2a60 
Step 4/5 : ENV NAME Bob 
 ---> Using cache 
 ---> cc432fe8ffb4 
Step 5/5 : ENTRYPOINT /go/bin/hello 
 ---> Using cache 
 ---> e0bbfb1fe52b 
Successfully built e0bbfb1fe52b 
 
# Let's now try to run the docker image. 
$ docker run hello-uncle
Bob is your uncle. 
 
# We can also change the environment variables on the fly. 
$ docker run  -e NAME=Sam hello-uncle
Sam is your uncle.
```

## Testing in Go

Testing is totes important.

Certain rules and conventions to follow:

* Source files and test files are placed in the same pkg/folder.
* The name of the test file for any given source is `[source_file_name]_test.go`.
* Test functions need to have the "Test" prefix.

We'll look at a handful of files and their tests:

* `variadic.go` and `variadic_test.go`.
* `addInt.go` and `addInt_test.go`.
* `nil_test.go`, with no source file for this test.

You'll see more concepts as we go through these.

### `variadic.go`

A variadic function is a function that can accept any number of arguments during a function call.

Given that Go is a statically typed language, the only limitation imposed by the type system on a
variadic function is that all arguments passed in should be of the same data type. However, it doesn't
limit you from passing other variable types. The arguments are received by the function as a slice of
elements if arguments are passed, else `nil`, when none are passed.

Here's the code:

```go
// variadic.go 
 
package main 
 
func simpleVariadicToSlice(numbers ...int) []int { 
   return numbers 
} 
 
func mixedVariadicToSlice(name string, numbers ...int) (string, []int) { 
   return name, numbers 
} 
 
// Does not work. 
// func badVariadic(name ...string, numbers ...int) {}
```

Notice the `...` prefix before the data type to define a fn as a variadic fn. Note that we can have
only one variadic param per fn and it has to be _the last param_. We can this error if we uncomment
the line for `badVariadic` and attempt to test the code.

### `variadic_test.go`

We would like to test the two valid functions, `simpleVariadicToSlice` and `mixedVariadicToSlice`,
for various rules defined in the previous section. Here's the brief overview of what we'll be testing:

* `simpleVariadicToSlice`: this is for no arguments, three arguments, and also to look at how to pass
a slice to a variadic fn.
* `mixedVariadicToSlice`: This is to accept a simple argument and a variadic argument.

Here's the test code:

```go
// variadic_test.go 
package main 
 
import "testing" 
 
func TestSimpleVariadicToSlice(t *testing.T) { 
    // Test for no arguments 
    if val := simpleVariadicToSlice(); val != nil { 
        t.Error("value should be nil", nil) 
    } else { 
        t.Log("simpleVariadicToSlice() -> nil") 
    } 
 
    // Test for random set of values 
    vals := simpleVariadicToSlice(1, 2, 3) 
    expected := []int{1, 2, 3} 
    isErr := false 
    for i := 0; i < 3; i++ { 
        if vals[i] != expected[i] { 
            isErr = true 
            break 
        } 
    } 
    if isErr { 
        t.Error("value should be []int{1, 2, 3}", vals) 
    } else { 
        t.Log("simpleVariadicToSlice(1, 2, 3) -> []int{1, 2, 3}") 
    } 
 
    // Test for a slice 
    vals = simpleVariadicToSlice(expected...) 
    isErr = false 
    for i := 0; i < 3; i++ { 
        if vals[i] != expected[i] { 
            isErr = true 
            break 
        } 
    } 
    if isErr { 
        t.Error("value should be []int{1, 2, 3}", vals) 
    } else { 
        t.Log("simpleVariadicToSlice([]int{1, 2, 3}...) -> []int{1, 2, 3}") 
    } 
} 
 
func TestMixedVariadicToSlice(t *testing.T) { 
    // Test for simple argument & no variadic arguments 
    name, numbers := mixedVariadicToSlice("Bob") 
    if name == "Bob" && numbers == nil { 
        t.Log("Recieved as expected: Bob, <nil slice>") 
    } else { 
        t.Errorf("Received unexpected values: %s, %s", name, numbers) 
    }
}
```

Running these tests are as simple as running `go test -v` (the `-v` is for _verbose_).

```
go test -v ./{variadic_test.go,variadic.go}
```

### `addInt.go`

These tests provide a good way to run multiple tests within a single function.

```go
// addInt.go 
 
package main 
 
func addInt(numbers ...int) int { 
    sum := 0 
    for _, num := range numbers { 
        sum += num 
    } 
    return sum 
}
```

One style of testing, known as Table-driven development, defines a table of all the required data to
run a test, iterates over the "rows" of the table and runs tests against them.

Let's look at the tests we will be testing against no arguments and variadic arguments:

```go
// addInt_test.go 
 
package main 
 
import ( 
    "testing" 
) 
 
func TestAddInt(t *testing.T) { 
    testCases := []struct { 
        Name     string 
        Values   []int 
        Expected int 
    }{ 
        {"addInt() -> 0", []int{}, 0}, 
        {"addInt([]int{10, 20, 100}) -> 130", []int{10, 20, 100}, 130}, 
    } 
 
    for _, tc := range testCases { 
        t.Run(tc.Name, func(t *testing.T) { 
            sum := addInt(tc.Values...) 
            if sum != tc.Expected { 
                t.Errorf("%d != %d", sum, tc.Expected) 
            } else { 
                t.Logf("%d == %d", sum, tc.Expected) 
            } 
        }) 
    } 
}  
```

Running the tests, we see each of the rows in the `testCases` table, which we ran, treated as
separate tests.

```
$ go test -v ./{addInt.go,addInt_test.go}                           
=== RUN   TestAddInt                       
=== RUN   TestAddInt/addInt()_->_0         
=== RUN   TestAddInt/addInt([]int{10,_20,_100})_->_130                                
--- PASS: TestAddInt (0.00s)               
    --- PASS: TestAddInt/addInt()_->_0 (0.00s)                                        
        addInt_test.go:23: 0 == 0          
    --- PASS: TestAddInt/addInt([]int{10,_20,_100})_->_130 (0.00s)                    
        addInt_test.go:23: 130 == 130      
PASS                                       
ok      command-line-arguments  0.001s
```

### `nil_test.go`

We can also create tests that are not specific to any particular source file, just that it has
the `[text]_test.go` naming format. The following test file will cover some useful extras
that might be quite useful when writing tests.

* `httptest.NewServer`: Imagine the case where we have to test our code against a server that sends
back some data. Starting and coordinating a full blown server to access some data is hard. The `http.
NewServer` solves this issue for us.
* `t.Helper`: If we use the same logic to pass or fail a lot of `testCases`, it would make sense to
segregate this logic into a separate function. However, this would skew the test run call stack. 
We can see this by commenting `t.Helper()` in the tests and rerunning `go test`.

We can also format our cl output to print pretty results. You'll see tick marks for passed cases
and cross marks for failed cases.

The test will run a test server, make `GET` requests on it, and then test the expected output:

```go
// nil_test.go 
 
package main 
 
import ( 
    "fmt" 
    "io/ioutil" 
    "net/http" 
    "net/http/httptest" 
    "testing" 
) 
 
const passMark = "\u2713" 
const failMark = "\u2717" 
 
func assertResponseEqual(t *testing.T, expected string, actual string) { 
    t.Helper() // comment this line to see tests fail due to 'if expected != actual' 
    if expected != actual { 
        t.Errorf("%s != %s %s", expected, actual, failMark) 
    } else { 
        t.Logf("%s == %s %s", expected, actual, passMark) 
    } 
} 
 
func TestServer(t *testing.T) { 
    testServer := httptest.NewServer( 
        http.HandlerFunc( 
            func(w http.ResponseWriter, r *http.Request) { 
                path := r.RequestURI 
                if path == "/1" { 
                    w.Write([]byte("Got 1.")) 
                } else { 
                    w.Write([]byte("Got None.")) 
                } 
            })) 
    defer testServer.Close() 
 
    for _, testCase := range []struct { 
        Name     string 
        Path     string 
        Expected string 
    }{ 
        {"Request correct URL", "/1", "Got 1."},
{"Request incorrect URL", "/12345", "Got None."}, 
    } { 
        t.Run(testCase.Name, func(t *testing.T) { 
            res, err := http.Get(testServer.URL + testCase.Path) 
            if err != nil { 
                t.Fatal(err) 
            } 
 
            actual, err := ioutil.ReadAll(res.Body) 
            res.Body.Close() 
            if err != nil { 
                t.Fatal(err) 
            } 
            assertResponseEqual(t, testCase.Expected, fmt.Sprintf("%s", actual)) 
        }) 
    } 
    t.Run("Fail for no reason", func(t *testing.T) {
        assertResponseEqual(t, "+", "-")
    })
}
```

Running the tests, you should see a singular failure with a tick mark.

```
$ go test -v ./nil_test.go                                          
=== RUN   TestServer                       
=== RUN   TestServer/Request_correct_URL   
=== RUN   TestServer/Request_incorrect_URL 
=== RUN   TestServer/Fail_for_no_reason    
--- FAIL: TestServer (0.00s)               
  --- PASS: TestServer/Request_correct_URL (0.00s)                                  
        nil_test.go:55: Got 1. == Got 1.  
  --- PASS: TestServer/Request_incorrect_URL (0.00s)                                
        nil_test.go:55: Got None. == Got None. 
  --- FAIL: TestServer/Fail_for_no_reason (0.00s)   
      nil_test.go:59: + != - 
 FAIL
 exit status 1
 FAIL command-line-arguments 0.003s
```

[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Understanding Goroutines 🔜][upcoming-chapter]

[readme]: README.md
[upcoming-chapter]: ch02-understanding-goroutines.md
[dep]: https://github.com/golang/dep
[docker-arch]: images/ch01-docker-arch.png
[docker-community]: https://www.docker.com/community-edition

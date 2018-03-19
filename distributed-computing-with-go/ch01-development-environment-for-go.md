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
 
$ # Let's now try to run the docker image. 
$ docker run hello-uncle
Bob is your uncle. 
 
$ # We can also change the environment variables on the fly. 
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

[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Understanding Goroutines 🔜][upcoming-chapter]

[readme]: README.md
[upcoming-chapter]: ch02-understanding-goroutines.md
[dep]: https://github.com/golang/dep
[docker-arch]: ch01-docker-arch.png
[docker-community]: https://www.docker.com/community-edition

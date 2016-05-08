[&lt;&lt; Back to the README](README.md)

# Chapter 1. Primer

## Why Care?

Unix programming concepts and techniques are not a fad, they're not the latest
popular programming language. These techniques transcend programming languages.

Smart programmers have been using Unix programming to solve tough problems with
a multitude of programming languages for the last 40 years.

## Harness the Power!

With this power you can create new software, understand complex software that
is already out there, even use this knowledge to advance your career to the
next level.

## Overview

This not a reference manual, it's more of a walkthrough.

Follow along with the code examples and run them yourself in a Ruby interpreter.
Once complete, have a look at the included Spyglass project. The very last
chapter has a deep introduction.

## System Calls

A quick explanation of the componenents of a Unix system, specifically userland
vs the kernel.

The kernel of your Unix system sits atop the hardware of your computer. It is a
middleman for any interactions that need to happen with the hardware. This
includes things like writing/reading from the filesystem, sending data over the
network, allocating memory, or playing audio over the speakers. Programs are not
allowed direct access to the kernel. Any communication is done via system calls.

The system call interface connects the kernel to userland. It defines the
interactions that are allowed between your program and the computer hardware.

userland is where all of your programs run/ You can do a lot without ever
making a system call: math, string ops, control flow with logical statements.
But if you want to do anything interesting you'll need to involve the kernel
via system calls.

C programmers tend get this pretty quickly.

System calls allow your user-space programs to interact indirectly with the
hardware of your computer, via the kernel.

## Nomenclature, wtf(2)

One of the roadblocks to learning about Unix programming is where to find the
proper documentation. Manpages make it available on your system.

`man man`

Manpages for the system call api are great resources in two situations:

1. you're a C programmer who wants to know how to invoke a given system call.
2. you're trying to figure out the purpose of a given system call.

Commonly used sections of the manpages for FreeBSD and Linux systems:

- Section 1: General Commands
- Section 2: System Calls
- Section 3: C Library Functions
- Section 4: Special Files

Section 1 is for general commands (shell commands). To refer to the manpage for
`find` you will see this: find(1). This tells you there is a manpage for `find`
in section 1 of the manpages.

For `getpid`: getpid(2).

### Why Do Manpages Need Multiple Sections?

Because a command may be available in more than one section, ie. a shell command
and a system call. Like stat(1) and stat(2)

To access other sections of the manpages, you can specify it on the command line:

```sh
man 2 getpid
man 3 malloc
man find # same as man 1 find
```

This is a standard convention:
[http://en.wikipedia.org/wiki/Man_page#Usage](http://en.wikipedia.org/wiki/Man_page#Usage )

## Processes: The Atoms of Unix

Process are the building blocks of a Unix system, because **any code that is
executed happens inside a process.**

When you launch `ruby` from the command line, a new process is created for your
code and it exits when your code is finished.

```sh
ruby -e "p Time.now"
```

The same is true for all code running on your system. From MySQL server, to an
e-reader, to email clents.

Things start to get interesting when you realize that one process can spawn and
manage many others.

[&lt;&lt; Back to the README](README.md)

# Chapter 2. Establishing Connections

TCP connections are made between two endpoints, on any two network interfaces
in the world, but the principles are the same regardless of them.

When you create a socket, it must assume one of two roles:

1. initiator
2. listener

Both roles are required.

In network programming the term used for a **socket that listens is a server**
and **a socket that initiates a connection is a client.**

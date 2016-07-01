[&lt;&lt; Back to the README](README.md)

# Chapter 8. Redis

Redis is like grease. It's most often used to lube moving parts and keep them
working smoothly by reducing friction and speed up their overall function.

> Redis = REmote DIctionary Service

Redis is a simple-to-use key-value store with a sophisticated set of commands.
Redis creator Salvatore Sanfilippo refers to his project as a "data structure
server" to capture its nuanced handling of complex datatypes and other features.

## 8.1 Data Structure Server Store

It can be a bit difficult to classify exactly what Redis *is*. It is a key-value
store, but that simple label doesn't really do it justice. It supports advanced
data structures, but not to the degree a document-oriented db would. It supports
set-based query operations, but not like a relational database. And it's *fast*,
trading durability for raw speed.

Redis is also a blocking queue (read: stack), and a publish-subscribe system. It
features configurable expiry policies, durability levels, and replication options.
This makes Redis more of a toolkit of useful data structure algorithms and processes
than a member of a specific db genre.

Redis' expansive list of client libs makes it a drop-in option for many programming
languages. It's not simply easy to use; it's a joy.

## 8.2 Day 1: CRUD and Datatypes

### Getting Started

You can install Redis a number of different ways. Once complete, if you need to
fire up the server, run:

```sh
redis-server
```

Then run the cli:

```sh
redis-cli
```

If you can't connect, type `help`.

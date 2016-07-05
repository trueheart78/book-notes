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

We'll use Redis to build the back-end for a URL shortenery, like tinyurl.com or
bit.ly. Visiting the short URL redirects users to the longer mapped URL, saves
the visitors from text messaging long strings, and also provides the short URL
creator some stats like visitor counts.

We can use the `SET` command to key a short code like `7wks` to a value like
http://www.sevenweeks.org. `SET` always takes two params, a key and a value.
Retrieving the value just needs `GET` and the key name.

```sh
SET 7wks http://www.sevenweeks.org
OK
GET 7wks
"http://www.sevenweeks.org/"
```

To reduce traffic, we can also set multiple values with `MSET`, like any number
of key-value pairs. Here we map Google to gog and Yahoo to yah.

```sh
MSET gog http://google.com yah http://yahoo.com
OK
MGET gog yah
1) "http://google.com"
2) "http://yahoo.com"
```

Although Redis stores stings, it recognizes integers and provides some somple
ops for them. If we want to keep a running total of how many short keys are in
our dataset, we can create a count and then increment it with the `INCR`
command.

```sh
SET count 2
OK
INCR count
(integer) 3
GET count
"3"
```

Although `GET` returns `count` as a string, `INCR` recognized it as an int and
added one to it. Doing so on a non-int ends poorly.

```sh
SET bad_count "a"
OK
INCR bad_count
(error) ERR value is not an integer or out of range
```

If the val can't be resolved to an int, Redis lets you know. There are also
other increment and decrement commands [`INCRBY`, `DECR`, `DECRBY`].

### Transactions

Redis' `MULTI` block atomic commands are similar to what Postgres and Neo4j
offer.  Wrapping 1+ ops like `SET` and `INCR` in a single block will complete
with either success or not at all. However, the ops will not ever be partial.

Transactions begin with the `MULTI` command and execute with the `EXEC` command.

```sh
MULTI
OK
SET prag http://pragprog.com
QUEUED
INCR count
QUEUED
EXEC
1) OK
2) (integer) 2
```

When using `MULTI`, the commands are not executed until they've been queued up.

You can stop a transaction with the `DISCARD` command, which will clear the
queue. However, it will not revert the database; it just will not run the trans
at all.

### Complex Datatypes

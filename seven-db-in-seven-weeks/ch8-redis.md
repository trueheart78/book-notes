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

Complex behavior is required for most programming and data storage problems.
Storing lists, hashes, sets, and sorted sets natively helps explain Redis'
popularity, and after exploring the complex ops you can enact on them, you are
likely to agree.

These collection datatypes can contain a huge number of values (up to 2^32
elements or more than 4 billion) per key. That's more than enough for all
Facebook accounts to live as a list under a single key.

Redis commands follow a good pattern. `SET` commands begin with `S`, hashes with
`H`, and sorted sets with `Z`. Lists commands start with an `L` for left or `R`
for right, depending on the direction of the op, like `LPUSH` or `RPUSH`.

#### Hash

Hashes are like nested Redis objects that can take any number of key-value
pairs. Let's use a hash to keep trach of users who sign up for our URL service.

Hashes are nice because they help you avoid storing data with artificial key
prefixes. The `:` is a matter of convention, with no deeper meaning in Redis.

```sh
MSET user:eric:name "Eric Redmond" user:eric:password s3cret
OK
MGET user:eric:name user:eric:password
1) "Eric Redmond"
2) "s3cret"
```

Instead of separate keys, we can create a hash that has its own key-value pairs.

```sh
HMSET user:eric name "Eric Redmond" password s3cret
OK
HVALS user:eric
1) "Eric Redmond"
2) "s3cret"
HKEYS user:eric
1) "name"
2) "password"
HGET user:eric password
"s3cret"
```

Unlike document datastores, hashes in Redis cannot nest. Hashes can only store
string values.

More commands exist to delete hash fields (`HDEL`), increment an int field by
some count (`HINCRBY`), or retrieve the number of fields in a hash (`HLEN`).

#### List


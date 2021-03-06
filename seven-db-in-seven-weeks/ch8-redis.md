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

Although Redis stores stings, it recognizes integers and provides some simple
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

Lists contain multiple ordered vals that can act both as queues and as stacks.
They also have more sophisticated actions for inserting somewhere in the middle
of a list, constraining list size, and moving vals between lists.

Let's let our users keep a wishlist of URLs they would like to visit. To create
a list of short-coded websites we'd like to visit, we set the key to
`USERNAME:wishlist` and push any number of values to the right (end) of the
list.

```sh
RPUSH eric:wishlist 7ks gog prag
(integer) 3
```

Like most collection val insertions, the Redis command returns the number of
vals pushed. You can get the list length annytime with `LLEN`.

Using the list range command `LRANGE`, we can retrieve any part of the list by
specifying the first and last postitions. Redis is zero-based, and a negative
position means the number of steps from the end.

```sh
LRANGE eric:wishlist 0 -1
1) "7wks"
2) "gog"
3) "prag"
```

`LREM` removes from the given key some matching vals. It also requires a number
to know how many to remove. Setting the count to 0 removes them all.

```sh
LREM eric:wishlist 0 gog
```

Setting the count greater than 0 will remove only that number of matches, and
setting it to a negative number but will remove from end-to-front (right side).

To remove and retrieve each val in the order we added them (like a queue), we
can pop them off the left (head) of the list.

```sh
LPOP eric:wishlist
"7wks"
```

To act as a stack, after you `RPUSH` the values, you would `RPOP` from the end
of the list. All these ops are performed in constant time.

On the previous combination of commands, you can use `LPUSH` and `RPOP` to
similar effect (a queue) or `LPUSH` and `LPOP` to be a stack.

Suppose we wanted to remove vals from our wishlist and move them to another
list of visited sites. To do this atomically, we might try wrapping pop and push
actions within a multiblock.

```ruby
redis.multi do
  site = redis.rpop('eric:wishlist')
  redis.lpush('eric:visited', site)
end
```

Because the multi block queues requests, the above actually will not work. But
Redis provides a single command for popping vals from the tail of one list and
pushing to the head of another: `RPOPLPUSH`

```sh
RPOPLPUSH eric:wishlist eric:visisted
"prag"
```

This is quite useful for queuing commands.

Be aware the `RPOPLPUSH` is the only option, there are no other commands like
`RPOPRPUSH`, or `LOPOLPUSH`, or `LPOPRPUSH` even. 

##### Blocking Lists

A simple messaging system where many clients can push comments and one client
(the digester) pops messages from the queue would be great for a social
activity. Redis provides a few blocking commands for this type of purpose.

Open another `redis-cli` terminal that will be the digester. The command to
block until a value exists is `BRPOP`. It also requires the key to pop a value
from, as well as a timeout (in seconds).

```sh
BRPOP comments 300
```

In the first console, push a message to comments:

```sh
LPUSH comments "Prag is great!"
```

Going back to the digester, you'll see two lines returned: the key, and the
value popped. You'll also see the length of time it spent blocking.

```sh
1) "comments"
2) "Prag is great!"
(50.22s)
```

There is also a blocking version of left pop, `BLPOP`, and right pop, left push
`BRPOPLPUSH`.

#### Set

Our URL shortener is coming along, but it would be nice to group common URLs in
some way.

Sets are unordered collections with no duiplicate values and are an excellent
choice for performing ops between two+ key vals, like unions or intersections.

```sh
SADD news nytimes pragprog.com
(integer) 2
```

Redis added two vals, and we can retrieve the full set (in no particular order)
via `SMEMBERS`.

```sh
SMEMBERS news
1) "pragprog.com"
2) "nytimes.com"
```

Now for tech:

```sh
SADD tech pragprog.com apple.com
(integer) 2
```

We can find the intersection of them using `SINTER`:

```sh
SINTER news tech
1) "pragprog.com"
```

We can also find all news sites that are not tech sites using `SDIFF`:

```sh
SDIFF news tech
1) "nytimes.com"
```

We can also union these, and dupes are dropped:

```sh
SUNION news tech
1) "apple.com"
2) "pragprog.com"
3) "nytimes.com"
```
That set of vals can also be stored directly into a new set using `SUNIONSTORE`:

```sh
SUNIONSTORE websites news tech
```

This also provides a useful trick for cloning a single key's vals to another key
like `SUNIONSTORE news_copy news`. There are similar commands for storing
intersections (`SINTERSTORE`) and diffs (`SDIFFSTORE`).

Just like `RPLOPLPUSH` moved vals from one list to another, `SMOVE` does the
same for sets;

And like `LLEN` finds the length of a list, `SCARD` (set cardinality) counts the
set; it's just harder to remember.

Since sets are not ordered, there are no left, right, or other positional
commands. Popping a random val from a set just requires `SPOP key`, and removing
vals is `SREM key value [value ...]`

Unlike lists, there are no blocking commands for sets.

#### Sorted Sets


[&lt;&lt; Back to the README](README.md)

# Chapter 9. Wrapping (Them) Up (Together)

## 9.1 Genres Redux

### Relational

Most common classic db pattern. Set-theory-based systems as 2D tables with rows
+ columns. Strictly enforced type with some added features, as in PostgresSQL's
array, jub, and JSON support.

#### Good For

* When you know the layout of the data, not necessarily how you'll use the data.
* You pay the complexity cost up front for query flexibility.
  * Great for orders to shipments, inventory to shopping carts.

#### Not-So-Good For

- Highly variable data
- Deeply hierarchical data
- Record-to-record variation
  - Think of a RDBMS for creatures in nature. Ugh.

### Key-Value

Simplest model. Maps simple keys to (possibly) more complex values, like a huge
hashtable. Simplicity here means very flexible implementations. Fast hash lookups,
so Redis is quite speedy. They are also easily distributed, so Riak aims for
simple-to-manage clusters.

#### Good For

* Not having to deal with indexes
* Horizonatally scalable
* Super fast
* Great for data that isn't highly relatable
  * Think user session data

#### Not-So-Good For

- No indexes
- No scanning
- Supports basically CRUD, nothing else

### Columnar

**stopped on page 805**

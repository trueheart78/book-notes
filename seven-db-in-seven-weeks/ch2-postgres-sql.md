[&lt;&lt; Back to the README](README.md)

# Chapter 2. PostgresSQL

The hammer of the db world. Set-theory-based system, implemented as 2D tables
with rows and columns. A classic, boring db, strong as an ox, open source and
free to use without any charge. No enterprise level costs here.

Great toolkits
+ triggers
+ stored procedures
+ advanced indexes

Data safety
+ ACID compliance

Mind share
+ very common relational ideas

You don't need to know how you plan to use the data. Normalization means
flexible queries. 

## History of the Name

Written in the early 70's, called the **Interactive Graphics and Retrieval System**
("Ingres" for short), and improved in the 80's as "post-Ingres" and shortened to
**Postgres**. Open source community picked up what was left off, in 1995, as
Postgres95. Renamed in 1996 to PostgresSQL to denote it's new SQL support.

## Battle Hardened

ALl the plugins you could want, transaction support, stored procedures, and
cross-platform. Unicode support, sequences, table inheritance, and subselects.
One of the most ANSI SQL-compliant relational dbs on the market. Fast, reliable,
supports large data, and is used in projects like Skype, US FAA, and France's CNAF.

## Packages to Add

+ table-func
+ dict_xsyn
+ _fuzzystrmatch
+ pg_trgm
+ cube

Creating a schema (aka db)

`createdb book`

Verify those extra packages are installed

`psql book -c "SELECT '1'::cube;"`

## Day 1: Relations, CRUD, and Joins

Db runs on port `5432` - you can connect using the `psql` shell.

`psql book`



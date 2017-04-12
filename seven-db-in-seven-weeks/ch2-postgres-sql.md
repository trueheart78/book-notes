[&lt;&lt; Back to the README](README.md)

# Chapter 2. PostgresSQL

[Day 1][day-1] | [Day 2][day-2] | [SQL File][sql-file]

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

All the plugins you could want, transaction support, stored procedures, and
cross-platform. Unicode support, sequences, table inheritance, and subselects.
One of the most ANSI SQL-compliant relational dbs on the market. Fast, reliable,
supports large data, and is used in projects like Skype, US FAA, and France's CNAF.

## Packages to Add

+ table-func
+ dict_xsyn
+ _fuzzystrmatch
+ pg_trgm
+ cube

On OS X, the following commands were necessary:

```
psql book -c "CREATE EXTENSION tablefunc"
psql book -c "CREATE EXTENSION dict_xsync" # did not work
psql book -c "CREATE EXTENSION fuzzystrmatch"
psql book -c "CREATE EXTENSION pg_trgm"
psql book -c "CREATE EXTENSION cube"
```

## Creating a Schema

Creating a schema / database. You can do this from outside of PG _if_ you have it
installed.

`createdb book`

Verify those extra packages are installed

`psql book -c "SELECT '1'::cube;"`

<a name='day-1'></a>

## Day 1: Relations, CRUD, and Joins

Db runs on port `5432` - you can connect using the `psql` shell.

`psql book`

PG prompts with the name of the database, followed by a `#` if you are an admin,
and a `$` if you are a regular user.

There are two ways to get help in PG: `\h`, used to get details about a SQL command,
and `\?`, to display a list of PG-focused commands.


To get help on a specific SQL term, use `\h SELECT` or whichever command you are
working with.

Before diving too deep into the world ofs PG, it is good to make sure you understand
SQL itself.

### Starting with SQL

Standard RDBMS.

#### Working with Tables

PG is a design-first datastore, where first the schema is designed, and then data
is entered that conforms to said definition.

```sql
CREATE TABLE countries (
  country_code char(2) PRIMARY KEY,
  country_name text UNIQUE
);
```

Data is then inserted in standard SQL fashion:

```sql
INSERT INTO countries (country_code, country_name)
VALUES ('us', 'United States'), ('mx', 'Mexico'),
       ('au', 'Australia'), ('de', 'Germany'),
       ('gb', 'United Kingdom');
```

Now, where there is a `UNIQUE` constraint on the table, let's see how the next
command fails:

```sql
INSERT INTO countries (country_code, country_name)
VALUES ('uk', 'United Kingdom');
```

will get you the following error:

```
ERROR:  duplicate key value violates unique constraint "countries_country_name_key"
DETAIL:  Key (country_name)=(United Kingdom) already exists.
```

PG follows the standard SQL commands like `DELETE`, `SELECT`, etc.

##### Foreign Keys

To make sure that any country code inserted into the database exists in our
`countries` table, we will use that as a reference.

```SQL
CREATE TABLE cities (
  name text NOT NULL,
  postal_code varchar(9) CHECK (postal_code <> ''),
  country_code char(2) REFERENCES countries,
  PRIMARY KEY (country_code, postal_code)
);
```

As a note, `text` can be a string of any length, `varchar` can be a string with
a maximum length, and `char` must be a string of a specific length.

Now try inserting a city that no country was entered for.

```SQL
INSERT INTO cities VALUES ('Toronto', 'M4C1B5', 'ca');
```

and you will get the following error:

```
ERROR:  insert or update on table "cities" violates foreign key constraint "cities_country_code_fkey"
DETAIL:  Key (country_code)=(ca) is not present in table "countries".
```

Since `country_code REFERENCES countries`, the `country_code` *must* exist in the 
`countries` table. This is called _maintaining referential integrity_. The
`REFERENCES` keyword constrains fields to another table's primary key, and ensures
our data is always correct. *Note:* `NULL` is a valid `country_code` because
`NULL` represents the lack of a value. To disallow a `NULL country_code` in the
`cities` table, you change the `country_code` creation line to one of the following:

- `country_code char(2) REFERENCES countries NOT NULL`
- `country_code char(2) REFERENCES countries MATCH FULL`

So, with an existing country:

```SQL
INSERT INTO cities VALUES ('Portland', '87200', 'us');
```

You should see the following `INSERT 0 1`, indicating success.

Let's correct the wrong postal code we assigned to Portland. It should really
be 97205:

```SQL
UPDATE cities SET postal_code = '97205' WHERE name = 'Portland';
```

#### Joins: Inner, Outer, Left, Right

Standard SQL joins.

#### Venues Table

```SQL
CREATE TABLE venues (
  venue_id SERIAL PRIMARY KEY,
  name varchar(255),
  street_address text,
  type char(7) CHECK ( type in ('public','private') ) DEFAULT 'public',
  postal_code varchar(9),
  country_code char(2),
  FOREIGN KEY (country_code, postal_code) REFERENCES cities (country_code, postal_code) MATCH FULL
);

-- add a record
INSERT INTO venues (name, postal_code, country_code) VALUES ('Crystal Ballroom', '97205', 'us');

-- add a record and get the generated venue_id
INSERT INTO venues (name, postal_code, country_code) VALUES ('Voodoo Donuts', '97205', 'us') RETURNING venue_id;
```

#### Events Table

```SQL
CREATE TABLE events (
  event_id SERIAL PRIMARY KEY,
  title varchar(100) NOT NULL,
  starts timestamp NOT NULL,
  ends timestamp NOT NULL,
  venue_id INTEGER,
  FOREIGN KEY (venue_id) REFERENCES venues (venue_id)
);

--- seed some data
INSERT INTO events (title, starts, ends, venue_id)
VALUES
('LARP Club', '2017-02-15 17:30:00', '2017-02-15 19:30:00', 2),
('April Fools Day', '2017-04-01 00:00:00', '2017-04-01 23:59:59', null),
('Christmas Day', '2017-12-25 00:00:00', '2017-12-25 23:59:59', null);
```

#### Indexes

Standard SQL indexes.

```SQL
CREATE INDEX cities_name ON cities (name);
```

You can also use the `UNIQUE` keyword to create an index.

For less-than/greater-than/equals-to matches, you can also define the index
type, like a B-tree, as it can match on ranged queries. This will keep full
table scans from happening on large datasets. 

```SQL
CREATE INDEX index_name ON table USING btree (column);
```

This type of index can be very helpful for dates, number comparisons, etc.

Need to see all indexes in the current schema?

`\di`

You'll see the foreign key(s) you created in the displayed list. If you just
need to see one, use `\di index_name` to see the details.

To see info about a table you have created, you can use `\d cities`.

<a name='day-2'></a>

## Day 2: Advanced Queries, Code, and Rules

### Aggregate Functions

You can do a sub-`SELECT` to grab the data that needs to be inserted.

```SQL
INSERT INTO events (title, starts, ends, venue_id)
  VALUES ('Taylor Swift', '2017-09-17 19:00:00', '2017-09-17 23:00:00', (
    SELECT venue_id
    FROM venues
    WHERE name = 'Crystal Ballroom'
  )
);
```

#### Insert More Data

For some of the next items, we'll need some more data.

```SQL
INSERT INTO venues (name, type, postal_code, country_code)
VALUES ('My Place', 'private', '97205', 'us');

INSERT INTO events (title, starts, ends, venue_id)
VALUES
('Wedding', '2017-02-26 21:00:00', '2017-02-26 23:00:00', 2),
('Dinner with Mom', '2017-02-26 18:00:00', '2017-02-26 20:30:00', 3),
('Valentine''s Day', '2017-02-14 00:00:00', '2017-02-14 23:59:59', null);
```

#### Count

```SQL
-- basic count of all records
SELECT count(*) FROM events;

-- basic count of all records with a custom column name
SELECT count(*) event_count FROM events;
```

To count all titles with the word `Day`, use the `%` for a wildcard `Like`
search:

```SQL
SELECT count(title) FROM events WHERE title LIKE '%Day%';
```

#### Min and Max

To get the first start time and last end time of all events at the Crystal
Ballroom, use `min` and `max`:

```SQL
SELECT min(starts), max(ends)
FROM events INNER JOIN venues
  ON events.venue_id = venues.venue_id
WHERE venues.name = 'Crystal Ballroom';
```

You should see something like the following:

```
         min         |         max
---------------------+---------------------
 2017-09-17 19:00:00 | 2017-09-17 23:00:00 
```

#### Grouping

To find the number of events at certain venues, you could do:

```SQL
SELECT venue_id, count(*)
FROM events
GROUP BY venue_id;
```

```
 venue_id | count
----------+-------
          |     3
        1 |     1
        3 |     1
        2 |     2
```

It's a nice list, and we can even filter by the `count` function.
With `GROUP BY`, you can use `HAVING` (it's basically a `WHERE` clause).

For popular venues:

```SQL
SELECT venue_id
FROM events
GROUP BY venue_id
HAVING count(*) >= 2 AND venue_id IS NOT NULL;
```

```
 venue_id | count
----------+-------
        2 |     2
```

You can use `GROUP BY` without any aggregate functions.

```SQL
SELECT venue_id FROM events GROUP BY venue_id;
```

```
 venue_id
----------

        1
        3
        2
```

This is quite common, so you can use `DISTINCT` to do this.

```SQL
SELECT DISTINCT venue_id FROM events;
```

### Window Functions

Aggregate quiers are a common SQL staple. _Window functions_, on the other
hand, are not quite so common.

Window functions are similar to `GROUP BY` queries in that they allow you to
run aggregate functions across multiple rows, allowing you to use built-in
aggregate functions without requiring every single field to be grouped to a
single row.

Try selecting the `title` column without grouping it:

```SQL
SELECT title, venue_id, count(*)
FROM events
GROUP BY venue_id;
```

```
ERROR:  column "events.title" must appear in the GROUP BY clause or be used in an aggregate function
```

We are counting up the rows by `venue_id`, and in the case of `LARP Club` and `Wedding`,
we have two titles for a single `venue_id`, thus causing uncertainity.

Whereas a `GROUP BY` clause will return one record per matching group value,
a window function can return a separate record for each row.

```SQL
SELECT title, count(*) OVER (PARTITION BY venue_id) FROM events;
```

```
      title      | count
-----------------+-------
 Taylor Swift    |     1
 LARP Club       |     2
 Wedding         |     2
 Dinner with Mom |     1
 April Fools Day |     3
 Christmas Day   |     3
 Valentine's Day |     3
```

Think of `PARTITION BY` akin to `GROUP BY`, but rather than grouping
the results outside of the `SELECT` attribute list, it returns grouped
values as any other field. In SQL terms, it returns the results of an
aggreate function `OVER` a `PARTITION` of the result set.

#### Transactions

All or nothing is how you want your groups of statements to run, so for that,
transactions are what you should reach for.

```SQL
BEGIN TRANSACTION;
  DELETE FROM events;
ROLLBACK;
SELECT * FROM events;
```

If you run the above, you'll not lose your events, due to the `ROLLBACK` statement.

Why are transactions important? Anytime you are modifying data that should _never_
be out of sync, they are quite helpful. Just imagine how they might log monetary
transactions in a bank.

```SQL
BEGIN TRANSACTION;
  UPDATE account SET total=total+5000.0 WHERE account_id = 1337;
  UPDATE account SET total=total-5000.0 WHERE account_id = 7331;
END
```

#### Store Procedures

_pg 75_


[day-1]: #day-1
[day-2]: #day-2
[sql-file]: pg-books.sql

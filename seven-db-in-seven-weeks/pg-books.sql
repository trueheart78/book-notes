-- countries
CREATE TABLE countries (
  country_code char(2) PRIMARY KEY,
  country_name text UNIQUE
);

INSERT INTO countries (country_code, country_name)
VALUES ('us', 'United States'), ('mx', 'Mexico'),
       ('au', 'Australia'), ('de', 'Germany'),
       ('gb', 'United Kingdom');

-- cities
CREATE TABLE cities (
  name text NOT NULL,
  postal_code varchar(9) CHECK (postal_code <> ''),
  country_code char(2) REFERENCES countries,
  PRIMARY KEY (country_code, postal_code)
);

INSERT INTO cities VALUES ('Portland', '87200', 'us');
UPDATE cities SET postal_code = '97205' WHERE name = 'Portland';

-- venues
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

-- events
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

-- indexing
CREATE INDEX cities_name ON cities (name);

-- aggregate functions - sub-select
INSERT INTO events (title, starts, ends, venue_id)
  VALUES ('Taylor Swift', '2017-09-17 19:00:00', '2017-09-17 23:00:00', (
    SELECT venue_id
    FROM venues
    WHERE name = 'Crystal Ballroom'
  )
);

INSERT INTO venues (name, type, postal_code, country_code)
VALUES ('My Place', 'private', '97205', 'us');

INSERT INTO events (title, starts, ends, venue_id)
VALUES
('Wedding', '2017-02-26 21:00:00', '2017-02-26 23:00:00', 2),
('Dinner with Mom', '2017-02-26 18:00:00', '2017-02-26 20:30:00', 3),
('Valentine''s Day', '2017-02-14 00:00:00', '2017-02-14 23:59:59', null);

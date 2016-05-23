# Book Club Notes :boom:

Reading a lot, figured this was as good a place as any to make some notes :heart:

Books :books:

1. [CoffeeScript](notes/coffeescript/README.md)
1. [Working with Unix Processes](notes/working-with-unix-processes/README.md) :heart:
1. [Working with Ruby Threads](notes/working-with-ruby-threads/README.md) :heart:
1. [Confident Ruby](notes/confident-ruby/README.md)
1. [Practical Object-Oriented Design in Ruby](notes/practical-object-oriented-design-in-ruby/README.md) :heart:
1. [Seven Databases in Seven Weeks](notes/seven-db-in-seven-weeks/README.md)

## Adding a Book

### Creating YAML for a Book

Books can be added by creating a `book-name.yml` file in the `yaml/` directory. 

You can create the YAML file by running:

```sh
./generate -c book-name
```

### Importing a Book

To generate the proper note structure for a new book, run:

```sh
./generate book-name
```

And follow the prompts.

## Sample Book YAML

```yaml
---
:title: An Awesome Book
:purchase: http://buyonline.example.com
:author: That One Girl
:homepage: http://www.thatonegirl.com/
:image: https://image.example.com/an-awesome-book/
:image_ext: jpg

:chapters:
  - The First Chapter
  - The Second Chapter
  - The Third Chapter
  - In Closing
```

## Sample Output

After you save the above as `yaml/sample-book.yml`, and
run `./generate sample-book`, you should see the following:

```
- Directory: an-awesome-book
- Title: An Awesome Book
- Purchase: http://buyonline.example.com
- Author: That One Girl
- Homepage: http://www.thatonegirl.com/
- Image? true [jpg]
   https://image.example.com/an-awesome-book/
- Chapters: 4
   01. The First Chapter - ch01-the-first-chapter.md
   02. The Second Chapter - ch02-the-second-chapter.md
   03. The Third Chapter - ch03-the-third-chapter.md
   04. In Closing - ch04-in-closing.md
---------------------
Import 'An Awesome Book' by That One Girl :: 4 chapters? (y/n)
```

Entering `y` will generate the proper files in the noted directory,
download the image (if it is valid), and inform you of this task:

```sh
**********************************************************************

Please add the following to the root README.md file:

1. [An Awesome Book](notes/an-awesome-book/README.md)

**********************************************************************

Book notes generated successfully.
```

## Development

Make sure bundler is installed, and then run `bundle install`.

Tests can be run with `bundle exec rake test`. Tests are written using Minitest.

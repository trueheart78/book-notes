# Book Club Notes :boom:

Reading a lot, figured this was as good a place as any to make some notes :heart:

Books :books:

1. [Working with Ruby Threads](working-with-ruby-threads/README.md)
1. [Confident Ruby](confident-ruby/README.md)
1. [Practical Object-Oriented Design in Ruby](poodr/README.md) :heart:
1. [Seven Databases in Seven Weeks](seven-db-in-seven-weeks/README.md)

## Adding a Book

Books can be added by creating a `book-name.yml` file in the `book_data/` directory. 

To generate the proper structure for a new book, run:

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

After you save the above as `book_data/sample-book.yml`, and
run `./generate sample-book`, you should see the following:

```sh
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

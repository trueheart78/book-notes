[&lt;&lt; Back to the README](README.md)

# Chapter 7. Processes Have Arguments

Every process has access to a special array called `ARGV`. It may differ from
language to language, but they all have something called 'argv'.

argv is short form for 'argument vector'. In other words: a vector, or array, of
arguments. It holds the arguments that were passed in to the current process on
the command line.

```sh
cat argv.rb
p ARGV
ruby argv.rb foo bar -va
["foo", "bar", "-va"]
```

## It's an Array! :heart:

Unlike the `ENV` not being a `Hash`, `ARGV` is simply an `Array`.

Some libraries will read from `ARGV` to parse command line options, for example.
You can programmatically change `ARGV` before they have a chance to see it
if you need to set defaults at runtime.

## In the Real World

The most common case for `ARGV` is probably for accepting filenames into a
program.

The other common use case is for parssing command line input. You can use
`optparse` (part of the Ruby stdlib).

You can do it by hand and skip that extra overhead for simple command line
options and do it by hand.

```ruby
# did the user request help?
ARGV.include?('--help')

# get the value of the -c option
ARGV.include?('-c') && ARGV[ARGV.index('-c') + 1]
```

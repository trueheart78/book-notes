[&lt;&lt; Back to the README](README.md)

# Writing Ruby Scripts That Respect Pipelines (Blog)

Pipes are so very powerful, and a wonderful part of the Unix philosophy.

## A Simple Utility

A straightforward script called `hilong`.

It takes a file as an argument and prints each line preprended with its length.
If the length is longer than 80 characters, it is highlighted in red.

```ruby
#!/usr/bin/env ruby

# A file is passed in as an argument
input = File.open(ARGV[0])

# escaped bash color codes
red = "\e[31m"
reset_color = "\e[0m"

maximum_line_length = 80

# For each line of the input...
input.each_line do |line|
  # Construct a string that begins with the length of this line
  # and ends with the content. The trailing newline is #chop'ped 
  # off of the content so we can control where the newline occurs.
  # The strings are joined with a tab character so that indentation
  # is preserved.
  output_line = [line.length, line.chop].join("\t")

  if line.length > maximum_line_length
    # Turn the output to red starting at the first character.
    output_line.insert(0, red)
    # Reset the text color back to what it was at the end of the
    # line.
    output_line.insert(-1, reset_color)
  end

  $stdout.puts output_line
end
```

Example usage:

```
 $ hilong Gemfile
17    source :rubygems
1
13    gem 'jekyll'
82    gem 'liquid', '2.2.2'         # The comment on this line is long-winded, not sure why... 
16    gem 'RedCloth'  
```

It takes a file as input and then puts the modified version onto `$stdout`.

## Introducing Pipes

### Piping Out

Let's pipe data to another utility.

```
$ hilong Gemfile | grep gem
```

This works just fine since we use `$stdout` for output.

```
$ hilong Gemfile | more
```

Now we get ugly escape codes in our output.

#### Is It a TTY?

So we should consider not using colored output if we're piping to another utility.
Or to a file.

Ruby's `IO#isatty` method (aliased as `IO#tty?`) can tell you if the output is attached
to a terminal. Calling it on `$stdout` when piping out will return `false`.

Here's the relevant changes:


```ruby
  # If the line is long and our $stdout is not being piped then we'll
  # colorize this line.
  if $stdout.tty? && line.size > maximum_line_length
    # Turn the output to red starting at the first character.
    output_line.insert(0, red)
    # Reset the text color back to what it was at the end of the
    # line.
    output_line.insert(-1, reset_color)
  end 

  $stdout.puts output_line
```

Now we can pipe out without worrying about color codes, and get some nice plain text.

### Piping In

_Study_

[&lt;&lt; Back to the README](README.md)

[hilong source]: https://gist.github.com/jstorimer/1465437

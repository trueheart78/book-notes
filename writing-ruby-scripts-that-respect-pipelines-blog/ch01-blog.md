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

Most Unix utilities also respond to pipes coming in, and treats them as input. Try that
on `hilong`:


```
$ cat Gemfile Gemfile.lock | hilong 
/Users/jessestorimer/projects/hilong/hilong:4:in `initialize': can't convert nil into String (TypeError)
from /Users/jessestorimer/projects/hilong/hilong:4:in `open'
    from /Users/jessestorimer/projects/hilong/hilong:4:in `<main>'
```

:skull:

`hilong` is only written to handle the input when providing a filename via `ARGV`. Let's
update that.

That's where `ARGF` comes in. It provides a consistent interface for raw data via pipes, plus
filenames passed via `ARGV`. An update:


```ruby
# Read input from files or pipes.
-input = File.open(ARGV[0])
+input = ARGF.read
```

Now, if something is passed in via `ARGV`, `ARGF` will consider a filename and call `IO#read` on
them sequentially. If `ARGV` is empty, then it reads from `$stdin` to grab data from the pipe.

**Note:** Unix utilities will ignore standard input if filenames are given.

Here are some ways the `hilong` utility can now be used:


```
$ hilong Gemfile
$ hilong Gemfile | more
$ hilong Gemfile > output.txt
$ hilong Gemfile Gemfile.lock
$ cat Gemfile* | hilong
$ cat Gemfile | hilong - Gemfile.lock
$ hilong < Gemfile
```

### Piping In Constantly

When the input never stops coming, in the case of `tail -f`, `hilong` will suppress output.

```
$ tail -f log/test.log | hilong
```

This is because `ARGF#read` is blocking until it receives EOF. Since `tail -f` never sends EOF,
it becomes a stalemate.

Now, let's read from `ARGF` one line at a time using `#each_line`:

```ruby
# Keep reading lines of input as long as they're coming.
ARGF.each_line do |line|
  # Construct a string that begins with the length of this line
  # and ends with the content. The trailing newline is #chop'ped 
  # off of the content so we can control where the newline occurs.
  # The string are joined with a tab character so that indentation
  # is preserved.
  output_line = [line.size, line.chop].join("\t")
```

So now, using `ARGF#each_line`, we can handle everything that comes our way.

### Bonus: Piping Out to `head`

Piping to head reads the first 10 lines of input, then closes the pipe

```
$ cat /dev/urandom | base64 -b 80 | hilong | head
```

Running the above will raise `Broken pipe - <STDOUT> (Errno::EPIPE)`.

The solution here is to wrap the code that writest o `$stdout` in a `begin` block
that rescues this exception:


```ruby
  begin
    $stdout.puts output_line
  rescue Errno::EPIPE
    exit(74)
  end
```

Using `exit(74)` tells it exit with a non-successful error code of 74, which
`sysexits` specifies this exit code represents an IO error, which seems relevant.

You can find the full code for `hilong` [on GitHub][hilong source].

### Bonus: Colorized Output

From the [follow up blog post][on colorized output].

Since many different utilities differ in their support of colorized output, supporting
a set of options to disable color would make good sense.

Ruby has `optparse` in its standard library, so update the `hilong` script to accept a
`--no-color` option.


```ruby
maximum_line_length = 80
colorized_output = true

require 'optparse'
OptionParser.new do |options|
  options.on("--no-color", "Disable colorized output") do |color|
    colorized_output = color
  end 
end.parse!

# Keep reading lines of input as long as they're coming.
while input = ARGF.gets
  input.each_line do |line|
    # Construct a string that begins with the length of this line
    # and ends with the content. The trailing newline is #chop'ped 
    # off of the content so we can control where the newline occurs.
    # The string are joined with a tab character so that indentation
    # is preserved.
    output_line = [line.size, line.chop].join("\t")

    # If the line is long and our $stdout is not being piped then we'll
    # colorize this line.
    if colorized_output && line.size > maximum_line_length
      # Turn the output to red starting at the first character.
      output_line.insert(0, red)
```

Keep in mind that `colorized_output` is assigned to `true` at the start, then
is changed to the value of the parsed option (if passed in). Nowhere do you see
`colorized_output` being set to `false`, it simply uses the `OptionParser` to
set it accordingly.

**Note:** `optparse` encourages best practices by recognizing certain conventions.
  eg. `--[no-]thing` for boolean options, `--arg` value for required options.

So `optparse` detects the `false` setting because the option begins with `--no`,
without any extra step necessary from us.

Also, the check for `$stdout.tty` has been removed, as it no longer matters, as an
option now exists for this feature.

```
$ hilong --no-color Gemfile
$ cat Gemfile Gemfile.lock | hilong --no-color | more
```

Thanks to `optparse`, there is also some nice documentation for it, as well.

```
$ hilong -h
Usage: hilong [options]
        --no-color                   Disable colorized output
```

Updating it to make it look better:


```ruby
require 'optparse'
OptionParser.new do |options|
  # This banner is the first line of the help documentation.
  options.banner = "Usage: hilong [options] [files]\n" \
    "Show character count for each line of input and highlight long lines."

  # Separator just adds a new line with the specified text.
  options.separator ""
  options.separator "Specific options:"

  options.on("--no-color", "Disable colorized output") do |color|
    colorized_output = color
  end

  # on_tail says that this option should appear at the bottom of
  # the options list.
  options.on_tail("-h", "--help", "You're looking at it!") do
    $stderr.puts options
    exit 1
  end
end.parse!
```

Now the docs look good:


```
$ hilong -h
Usage: hilong [options] [files]
Show character count for each line of input and highlight long lines.

Specific options:
        --no-color                   Disable colorized output
    -h, --help                       You're looking at it!
```

Much better.

### Bonus: Moar Options

Let's use `optparse` to allow the max line length to be configurable.


```ruby
  end

  options.on("-m", "--max NUM", Integer, "Maximum line length") do |max|
    maximum_line_length = max
  end
end.parse!
```

So `optparse` is assuming things again. It is set to detect an `Integer` along
with the `-m` or `--max` option. The result is assigned to the previously existing
local variable.

Now, it's even better.

```
$ cat Gemfile* | hilong --max 20
$ hilong --m 140 Gemfile
$ hilong --max=180 Gemfile
```

If you try to pass something besides an `Integer` to `max`, then `optparse` will
let you know. You can see the [OptionParser docs][option parser] for more details.

[&lt;&lt; Back to the README](README.md)

[hilong source]: https://gist.github.com/jstorimer/1465437
[on colorized output]: https://www.jstorimer.com/blogs/workingwithcode/7766123-on-colorized-output
[option parser]: http://www.ruby-doc.org/stdlib-2.5.0/libdoc/optparse/rdoc/OptionParser.html

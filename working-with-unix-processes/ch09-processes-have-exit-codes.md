[&lt;&lt; Back to the README](README.md)

# Chapter 9. Processes Have Exit Codes

When a process comes to an end, it has one last chance to make its mark on the
world: its exit code. Every process that exits does so with a numeric exit code
(0-255) denoting success or error.

**An exit code of 0 is said to be successful**.

Just handle each error code the way your program needs to, don't worry much
about what all the codes mean.

Do stick with the '0 as success' exit code tradition, so your programs will
play nicely with other Unix tools.

## How to Exit a Process.

### `exit`

The simplext way to exit a process is `Kernel#exit`. This is also what happens
when your script ends without an explicit exit statement.

```ruby
# exit with status code 0
exit

# exit with custom exit code
exit 22

# Kernel#at_exit will run on exit.
at_exit { puts 'Last!' }
exit
```

The last part will output:

```
Last!
```

### `exit!`

Like `#exit`, but it sets an unsuccessful status code by default (of `1`), and
it won't run `#at_exit`.

```ruby
# exit with status code of 1
exit!

# also supports custom codes
exit! 33

# and doesn't run at_exit code
at_exit { puts 'Silence' }
exit!
```

### `abort`

Supports messages but not custom status codes, sets a status code of `1`.

```ruby
# exits with exit code 1
abort

# supports a message for STDERR
abort "Something went wrong."

# runs #at_exit code
at_exit { puts 'Last!' }
abort "Terrible things happened"
```

The last part will output:

```
Terrible things happened
Last!
```

### `raise`

You can also throw an unhandled except to end a process. Ending a process this
way will still invoke any `at_exit` handlers, and will print the exception
message and backtrace to `STDERR`.

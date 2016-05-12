[&lt;&lt; Back to the README](README.md)

# Chapter 6. Processes Have an Enviroment

Environment, in this sense, refers to 'environment variables'. The are key-value
pairs that hold data for a process.

Every process inheritis environment variables from its parent. They are set by a
parent process and inherited by its child processes. Environment variables are
per-process and are global to each process.

```sh
MESSAGE='wing it' ruby -e "puts ENV['MESSAGE']"
```

The `VAR=value` syntax is the `bash` way of setting environment variables. You
can also do the same thing from within Ruby using the `ENV` constant.

```ruby
ENV['MESSAGE'] = 'wing it'
system "echo $MESSAGE"
```

Both of the above examples output the following:

```
wing it
```

In `bash`, environment vars are accessed using the syntax: `$VAR`. As you can
tell, they can be used to share state between processes running different
languages, `bash` and `ruby` in this case.


## It's a Hash, Right?

Although `ENV` uses the hash-style accessor API it's not actually a `Hash`. Key
methods like `merge` don't exist for it. You can do `ENV.has_key?` but not all
hash operations work.

## In the Real World

You will find `RAILS_ENV`, `EDITOR`, and `QUEUE`, as well as many others, in
the wild. They are a generaic way to accept input into a command-line program.

They are also often less overhead than explicitly parsing command line options.

## System Calls

There are no system calls for directly manipulating environment vars, but the
C library functions setenv(3) and getenv(3) do the brunt of the work. Also see
environ(7) for an overview.

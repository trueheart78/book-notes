[&lt;&lt; Back to the README](README.md)

# Chapter 3. Processes Have Parents

Every process running on your system has a parent process, and can be identified
by **ppid**.

Generally, the ppid will be the process that invoked it.

The parent of that new bash process will be the Terminal.app process. If you
then invoke ls(1) from the bas prompt, the parent of that `ls` process will be
the `bash` process.

```ruby
puts Process.ppid
```

## Cross Referencing

Leave the `irb` session above open and run the following in a terminal:

```sh
ps -p [irb_parent_process_id]
```

You will see a process called 'bash' or 'zsh' with a pid that matches the one
that was printed in your `irb` session.

## In the Real World

There are not a ton of uses for ppid in the real world. It can be useful, though,
when detecting daemon processes.

## System Calls

Ruby's `Process.ppid` maps to getppid(2).

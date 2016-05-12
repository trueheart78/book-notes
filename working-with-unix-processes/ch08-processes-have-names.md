[&lt;&lt; Back to the README](README.md)

# Chapter 8. Processes Have Names

There are two mechanisms that operate at the level of the process itself that
can be used to communicate information. The **process name**, and **exit codes**.

## Naming Processes

Every process on the system has a name. `irb` is given the name 'irb'.

And yes, you can change them at runtime.

In Ruby, you can access the name of the current process in the `$PROGRAM_NAME`
variable. You can also assign a value to that global to change the name of the
current process.

```ruby
puts $PROGRAM_NAME

10.downto(1) do |num|
  $PROGRAM_NAME = "Process: #{num}"
  puts $PROGRAM_NAME
end
```

outputs:

```
irb
Process: 10
Process: 9
Process: 8
Process: 7
Process: 6
Process: 5
Process: 4
Process: 3
Process: 2
Process: 1
```

As a fun exercise, you can start an `irb` session, print the pid, and change
the process name. You can then use the ps(1) utility to see your changes on
your system.

However, this gloval variable (and its mirror `$0`) is the only way in Ruby
for this feature.

## In the Real World

To see an example of how this is used in a real project, read through
*How Resque Manages Processes* in the appendices.

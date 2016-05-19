[&lt;&lt; Back to the README](README.md)

# Chapter 14. Zombie Processes

If we don't clean up child processes appropriately, zombies can occur.

## Goot Things Come to Those Who wait(2)

The kernel queues up status info about child processes that have exited, so `Process.wait` can be called long after the child process has exited, with
the status info still available.

If the kernel never requests the status then the kernel can never reap that status info.

**If you are not going to wait for a child process to exit using `Process.wait`
(or the technique coming up in the next chapter), then you need to 'detach' the
child process.**

```ruby
message = 'Good Morning'
recipient = 'tree@mybackyard.com'

pid = fork do
  StatsCollector.record message, recipient
end

Process.detach(pid)
```

`Process.detach` spawns a new thread whose sole job is to wait for the child
process specified by the pid to exit. This keeps the kernel from hanging onto
any status info no longer needed.

## What Do Zombies Look Like?

```ruby
pid = fork { sleep 1}

puts pid

sleep 5
```

Running the following command, using the pid from the last snipped, will print
the status of the zombie process. It should say 'z' or 'Z+', meaning it is a 
zombie process.

```sh
ps -ho pid,state -p [pid]
```

## In The Real World

Notice that any dead process whose status hasn't been waited on is a zombie
process. So *every* child process that dies while the parent is active will be
a zombie, if only for a short time.

It is fairly uncommon to fork a child process in a fire and forget manner,
not ever collecting their status. A dedicated background queueing system should
be used.

You should take a look at a Gem called [Spawnling](https://github.com/tra/spawnling)

## System Calls

No system call for `Process.detach` as it is implemented in Ruby as a thread
and `Process.wait`.

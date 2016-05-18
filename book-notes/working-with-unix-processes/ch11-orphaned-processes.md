[&lt;&lt; Back to the README](README.md)

# Chapter 11. Orphaned Processes

## Out of Control

When you include a child process, it's no longer to control everything from
a terminal as we are used to doing.

```ruby
fork do
  5.times do
    sleep 1
    puts "I'm an orphan!"
  end
end

abort "Parent process died..."
```

## Abandoned Children

**Nothing happens to a child process when its parent dies.**

## Managing Orphans

Daemon processes are long running processes that are intentionally orphaned
and meant to stay running forever.

You can use Unix signals to communcate with processes that are not attached to
a terminal session.

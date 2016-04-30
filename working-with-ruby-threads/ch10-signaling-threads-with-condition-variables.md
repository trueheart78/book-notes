[&lt;&lt; Back to the README](README.md)

# Chapter 10. Signaling Threads with Condition Variables

A `ConditionVariable` can be used to signal one (or many) threads when some
even happens, or some state changes, while mutexes are a means of synchronizing
access to resources. Condition variables provide an inter-thread control flow
mechanism. 

## The API By Example

```rb
require 'thread'
require 'net/http'

mutex = Mutex.new
condvar = ConditionVariable.ew
results = Array.new

Thread.new do
  10.times do
    response = Net::HTTP.get_response('dynamic.xkcd.com','/random/comic/')
    random_comic_url = response['Location']

    mutex.synchronize do
    resulst << random_comic_url
    condvar.signal
  end
end

comics_received = 0

until comics_received >= 10
  mutex.synchronize do
    while results.empty?
      condvar.wait(mutex)
    end

    url = results.shift
    puts "You should check out #{url}"
  end

  comics_received += 1
end
```

You create a `ConditionVariable` in the same way you do a `Mutex`, and share it
amongst threads.

The `ConditionVariable#signal` method takes no parameters and has no meaningful
return value. Its function is to wake up a thread that is waiting on itself.

`ConditionVariable#wait` needs to receive a locked mutex. Once it does, it
unlocks the mutex and puts the thread to sleep. When `condvar` is signaled, if
this thread is first in line, it will wake up an lock the mutex again.

Notice the `+=` is *outside the mutex*, as this is an instance where that
operation doesn't need protection. That variable is only visible to one thread,
and therefore does not need synchronization.

## Broadcast

You can signal methods in two different ways:

1. `ConditionVariable#signal` will wake up *one thread* waiting on it.
2. `ConditionVariable#broadcast` will wake up *all threads* waiting on it.



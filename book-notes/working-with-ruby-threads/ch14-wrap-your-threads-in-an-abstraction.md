[&lt;&lt; Back to the README](README.md)

# Chapter 14. Wrap Your Threads in an Abstraction

This chapter is focused on turning you away from simple apps you may run
locally and more on the real world of production.

## Single Level of Abstraction

> "One level of abstraction per function" - Bob Martin

It states that all code in a given function should be at the same level of
abstraction, so don't intermingle low-level and high-level code in the same
function. They just don't mix well.

Threads are low-level concepts with their own complexities. Your OS provides it,
and is likely not part of the domain logic of your app.

**It's best to wrap threads in an abstraction where possible.** This is a
guideline, however, and not a rule.


Remember the simple `FileUploader` class from the beginning of the book?
We can make it much better if we put the abstraction in the correct place.

```rb
module Enumerable
  def concurrent_each
    threads = []

    each do |element|
      threads << Thread.new {
        yield element
      }
    end

    threads.each(&:join)
  end
end


require 'thread'
require_relative 'concurrent_each'

class FileUploader
  attr_reader :results

  def initialize(files)
    @files = files
    @results = Queue.new
  end

  def upload
    @files.concurrent_each do |(filename, file_data)|
      status = upload_to_s3(filename, file_data)
      @results << status
    end
  end

  def upload_to_s3(filename, file)
    # omitted
  end
end

uploader = FileUploader.new('boots.png'=>'data-here','shirts.png'=>'data-here')
uploader.upload

puts uploader.results.size
```

The above is a lot easier to read, at-a-glance.

## Actor Model

In some cases it will make sense to write your own simple abstractions on top
of your multi-threaded code, as in the above example.

In other cases, you'll get more benefit from a more mature abstraction.

The Actor model is a well-known and proven technique for doing multi-threaded
concurrency. 

An Actor is a long-lived 'entity' that communicates by sending messages.
Long-lived as in a long-running thread, not something that is spawned ad-hoc.

You can see this as part of [Celluloid](http://celluloid.io) and
[rubinius-actor](https://github.com/rubinius/rubinius-actor).

We'll be looking at Celluloid here.

Celluloid takes the conceptual idea of the Actor model and marries it to
Ruby's object model.

```rb
require 'celluloid/autostart'
require 'net/http'

class XKCDFetcher
  include Celluloid

  def next
    response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
    random_comic_url = response['Location']

    random_comic_url
  end
end
```

Notice the only real difference between this class and a regular Ruby class is
the inclusion of the `Celluloid` module. **This module inclusion turns instances
of the class into full-fledged Celluloid actors.**

Each Celluloid actor is housed by a separate thread, one thread per actor.

When you create a new actor, you immediately know its' address'. So long as you
hold a reference to that object, you can send it messages. 

```rb
# spawns a new thread containing a Celluloid actor
fetcher = XKCDFetcher.new

# these behave like regular method calls
fetcher.object_id
fetcher.inspect

# this will fire the 'next' method without waiting for its results
fetcher.async.next
fetcher.async.next
```

Regulare method calls are sent to the actor's mailbox, but Celluloid will block
the caller until it receives the result, just like a regular method call.

Celluloid also allows you to send a message to the actor's mailbox without
waiting for the result. You can fire off some work and move on.

The `async` is good if you don't care about the result, but what about getting
the result back? That's what Celluloid futures accomplish.

```rb
fetcher = XKCDFetcher.new
futures = []

10.times do
  futures << fetcher.future.next
end

futures.each do |future|
  puts "Here's a URL: #{future.value}"
end
```

Calling `#value` on a future object will block until the value has been
computed.

This is the basic idea behind Celluloid. It has many more features that can be
found on the [Celluloid Wiki](https://github.com/celluloid/celluloid/wiki), but
this concept of 'objects as actors' is really at its core.

Each class that includes the `Celluloid` module will spawn as their own thread.


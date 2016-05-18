[&lt;&lt; Back to the README](README.md)

# Chapter 15. How Sidekiq Uses Celluloid

*Note: Sidekiq 4.0 no longer uses Celluloid, but still highly recommends it
for concurrency*

Sidekiq is a multi-threaded background job processing system backed by Redis.
However, you won't find any `Thread.new` or `Mutex#synchronize` calls in the
code. This is because the multi-threaded processing is implemented on top of
Celluloid.

> "As soon as you introduce the `Thread` constant, you've probably just
   introduced 5 new bugs into your code." - Mike Perham, Sidekiq author

Sidekiq is comprised of Celluloid actors. A Manager actor at the top,
and collaborator actors, which are the Fetchers and Processors.

## The Manager Actor

### fetch

Once the manager has been initialized, it is started with the `start` method.

```rb
def start
  @ready.each { dispatch }
end

def dispatch
  return if stopped?

  # verifies we haven't leaked processes
  raise 'Bug: No processors, cannot continue!' if @ready.empty? && @busy.empty?
  raise 'No ready processor!' if @ready.empty?

  @fetcher.async.fetch
end
```

The last line will send the `fetch` message to the `@fetcher` actor and
*will not* wait for the return value. This is a fire-and-forget call where the
message is sent, but the Manager doesn't wait for the response.

Since the `fetch` message is asynchronous, it can be sent multiple times and
queued in the Fetcher actor's mailbox until it can process the backlog.

An excerpt from the `Fetcher#fetch` method.

```rb
work = @stratgey.retrieve_work

if @work
  @mgr.async.assign(work)
else
  after(0) { fetch }
end
```

If it doesn't retrieve any work, it calls iteself again. Since the manager sent
the `fetch` method, but is not waiting for a return value, the Fetcher is free
to take as long as necessary before sending a message back to the Manager.

When it's finally able to retrieve work, it asynchronously sends the `assign`
message to the Manager, passing along the unit of work.

### assign

`Manager#assign` that receives a unit of work

```rb
def assign(work)
  watchdog('manager#assign died') do
    if stopped?
      # race condition between Manager#stop if Fetcher is blocked on Redis and
      # gets a message after all the ready Processors have been stopped.
      # Push the message back to Redis.
      work.requeue
    else
      processor = @ready.pop
      @in_rpogress[processor.object_id] = work
      @busy << processor
      processor.async.process(work)
    end
  end
end
```

Since the Manager actor lives in its own thread, a standard Ruby array can be
used, as no thread-safety issues will arise.

Finally, it sends a message back to the Processor to perform the work. It will
send a message back to the manager when it is finished.

## Wrap-Up

You saw how Sidekiq handled the `fetch`, `assign`, and `process` messages.
This paradigm should feel a bit different from traditional Ruby code. You could
achieve the same behavior with something like the following:

```rb
class Manager
  def dispatch
    loop do
      work = @fetcher.fetch
      result = processor_pool.process(work)
      log_result(result)
    end
  end
end
```

The main difference between the Sidekiq codebase and a more traditional Ruby
codebase is the lack of dependence upon return values.

In Sidekiq, when an acttor sends a message, they expect a message to be sent
back to them in return. This keeps things asynchronous.

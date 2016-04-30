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

The last ling will send the `fetch` message to the `@fetcher` actor and
*will not* wait for the return value. This is a fire-and-forget call where the
message is sent, but the Manager doesn't wait for the response.



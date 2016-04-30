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



[&lt;&lt; Back to the README](README.md)

# Chapter 13. Thread-Safety on Rails

Puma and/or Sidekiq usage means that your app is running multi-threaded.

If you stick to Rails conventions, and write idiomatic Rails code, your Rails
app will be thread-safe.

## Gem Dependencies

Any gems you depend on need to be thread-safe. Check bug trackers if you are
not sure.

## The Request is the Boundary

A multi-threaded web server will process each request with a separate thread.

If you know that each request is handled by a separate thread, then the path
to thread-safety is clear: **don't share objects between requests.**

Make sure that each controller action creates the objects it needs to work with,
rather than sharing them between requests via a global reference.

Think of `User.current`. If you need this to be thread-safe, it's up to you to
implement it.

The same heuristic is applicable to a background job processor. Each job will
be handled by a separate thread. A thread may process multiple jobs in its
lifetime, but a job will only be processed by a single thread in its lifecycle.

**Create the necessary objects that you need in the body of the job, rather than
sharing an global state.**

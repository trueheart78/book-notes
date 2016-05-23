[&lt;&lt; Back to the README](README.md)

# Chapter 17. Closing

Working with concurrency is all about organization.

Our job is to organize our code such that the system can run it in the most
efficient way possible. Multi-threading is one way to do this, but then we need
to make sure that our code is ogranized to preserve thread safety.

Workig with concurrency is about balancing these elements of organization.

Concurrency isn't something that should be used everywhere, not in every app,
and not in every part of your app. Know where to apply it, and where to restrict
it.

An eloquent set of rules can be found on the
[JRuby wiki](https://github.com/jruby/jruby/wiki/Concurrency-in-jruby#concurrency_basics):

The safest path to concurrency:

1. Don't do it.
2. If you must do it, don't share data across threads.
3. If you must chare data across threads, don't share mutable data.
4. If you must share mutable data across threads, synchronize access to that
   data.

If you stick to these rules, you'll strike that balance.

## Ruby Concurrency Doesn't Suck

Ruby's concurrency story is much better today than it has been in the past. 
While MRI still has a GIL, there are alternatives (JRuby and Rubinius) that
support true parallel threading.

Celluloid certainly helps, as well.

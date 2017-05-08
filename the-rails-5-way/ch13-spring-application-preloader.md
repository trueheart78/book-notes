[&lt;&lt; Other Common Initializers](ch12-other-common-initializers.md) | [README](README.md) | [Development Mode &gt;&gt;](ch14-development-mode.md)

# Chapter 13. Spring Application Preloader

Rails ships with an app preloader named Spring. Unless you disable it, during
development your app process will keep running in the background continuously.
It speeds up development by eliminating the need to boot up Rails _from scratch_
every time you execute tests or run a `rake` task.

While running, Spring monitors folders `config` and `initializers` for changes. If
a file within those folders is changed, Spring will restart your app for you. It
will also restart if any gem dependencies are changed during development.

To demonstrate the speed increase Spring provides, compare the same `rake` task
run in both Rails 4.0 and a preloaded 4.1 app:

```
# Rails 4.0
$ time bin/rake about
  ...
  bin/rake about  1.20s user 0.36s system 22% cpu 6.845 total

# Rails 4.1
$ time bin/rake about
  ...
  bin/rake about  0.08s user 0.04s system 32% cpu 0.370 total
```

The preloaded Rails env using Spring saves over 6 seconds, which will add up over
time.

You can tweak the Spring settings in `config/spring.rb`:

```ruby
%w(
  .ruby-version
  .rbenv-vars
  tmp/restart.txt
  tmp/caching-dev.txt
).each { |path| Spring.watch(path) }
```

[&lt;&lt; Other Common Initializers](ch12-other-common-initializers.md) | [README](README.md) | [Development Mode &gt;&gt;](ch14-development-mode.md)

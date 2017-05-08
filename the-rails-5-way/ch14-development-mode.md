[&lt;&lt; Spring Application Preloader](ch13-spring-application-preloader.md) | [README](README.md) | [Test Mode &gt;&gt;](ch15-test-mode.md)

# Chapter 14. Development Mode

Development is the default Rails mode, which is where you will spend most of your
time as a developer. This section contains an in-depth explanation of each setting
in `config/environments/development.rb`.

```ruby
Rails.application.configure do
  # Settings specified here will take precedence over those in
  # config/application.rb.
```

## Automatic Class Reloading

One of the signature benefits of using Rails is the quick feedback cycle offered
by its dev mode. Make changes to your code, hit Reload in your browser, and (like
magic), the changes are reflected in your app. This behavior is governed by the
`config.cache_classes` setting:

```ruby
# In the development environment your application's code is reloaded on
# every request. This slows down response time but is perfect for
# development since you don't have to restart the web server when you
# make code changes.
config.cache_classes = false
```

Without getting into too much detail, when the above setting is `true`, Rails
will use Ruby's `require` statement to do its class loading, and when it is
`false`, it will use `load` instead.


[&lt;&lt; Spring Application Preloader](ch13-spring-application-preloader.md) | [README](README.md) | [Test Mode &gt;&gt;](ch15-test-mode.md)

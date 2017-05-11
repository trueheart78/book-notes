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

When you require a Ruby file, the interpeter executes and caches it. If the file
is required again (as in subsequent requests), the `require` statement is ignored
and Rails moves on. When you load a Ruby file, the interpeter executes the file
again, no matter how many times it has been loaded before.

### The Rails Class Loader

In Ruby, a script file doesn't need to be named in any particulare way that
matches its contents. That is not the case in Rails.

When Rails encounters an undefined constant in the code, it uses a class
loader routine (based on file-naming conventions) to find and require the
needed Ruby script.

### Rails, Modules, and Auto-Loading Code

Normally in Ruby, you use `require` statements to include scripts. Rails,
however, implements a simple convention that enables it to automatically load
your code (in most cases).

**How it works:** If Rails encounters a class or module in your code that is
not already defined, it uses the following convention to guess which file(s) it
should require to load.

If not nested, you get `SampleClass` existing in `sample_class.rb`. If nested,
you get directory structures added. For `CantEven::SampleClass::ExtraModule`,
it looks for a `cant_event/sample_class/extra_module.rb` file.

## Eager Load

To speed up the boot time of starting a Rails server inside dev, your code and
libraries are not eager loaded into memory. Instead, they are loaded on an
as-needed basis (read: "lazy loading"). This is governed by the `config.eager_load`
setting:

```ruby
# Do not eager load code on boot.
config.eager_load = false
```

In prod, this should be set to `true`, as it copies most of your app into memory.

## Error Reports

Requests from localhost, like during dev, generate useful error messages that
include debugging info (like line number). Setting `consider_all_requests_local`
to `true` causes Rails to display those dev-friendly error screens even when the
machine making the request is remote. Total edge-case, though.

```rb
config.consider_all_requests_local = true
```

## Caching

You normally don't want caching behavior when you are in dev mode, unless you are
actually testing caching. See the
[Caching and Performance chapter][caching-and-performance] for more details.

## Action Mailer Settings

Rails assumes you do not want Action Mailer to raise delivery exceptions in dev
mode, so based on the `config.action_mailer.raise_delivery_errors` settings, it
will swallow said exceptions.

```ruby
# Don't care if the mailer can't send.
config.action_mailer.raise_delivery_errors = false
```

If you actually want to send mail in dev mode, then setting this to `true` is
advised _during_ those times.

**If you want to see the emails _but do not want them delivered_**, you can set
`config.action_mailer.perform_deliveries = false` and then check the mail in the
log file to verify that it looks correct.

Action Mailer **also supports caching**, but it is defaulted to `false`. If `true`,
Action Mailer will not ignore `cache` methods called in mailer view templates.

```ruby
config.action_mailer.perform_caching = false
```

## Deprecation Notices

Deprecation warnings are very useful for letting you know when you should stop
using a certain part of functionality. In dev mode, this is set to show in the
Rails logger.

```ruby
# Print deprecation notices to the Rails logger.
config.active_support.deprecation = :log
```

## Pending Migrations Error Page

In previous versions of Rails, if pending migrations needed to be run, the web
server would fail to start. Since Rails 4, a new error page is displayed to
inform devs of the need.

```ruby
# Raise an error on page load if there are pending migrations
config.active_record.migration_error = :page_load
```

## Assets Debug Mode

In dev mode, JS and CSS files are served separately in the order they were
specified. Setting `config.assets.debug` to `false` would result in Sprockets
concatenationg and running preprocessors on all assets.

```ruby
# Debug mode disables concatenation and preprocessing of assets.
config.assets.debug = true

# Suppress logger output for asset requests.
config.assets.quiet = true
```

Dev mode also omits logger output for asset requests, as an FYI.

## Missing Translations

Rails views normally just print the key for missing translations, since that's
what you want when you're developing prior to translation activities taking place.

```ruby
# Raises error for missing translations
config.action_view.raise_on_missing_translations = true
```

[&lt;&lt; Spring Application Preloader](ch13-spring-application-preloader.md) | [README](README.md) | [Test Mode &gt;&gt;](ch15-test-mode.md)

[caching-and-performance]: ch188-caching-and-performance.md

[&lt;&lt; Default Initializers](ch11-default-initializers.md) | [README](README.md) | [Spring Application Preloader &gt;&gt;](ch13-spring-application-preloader.md)

# Chapter 12. Other Common Initializers

While the following settings are not included in the Rails boilerplate, they
are sufficiently common enough that you should be aware of them.

## Time Zones

The default time zone for Rails apps is UTC. This can be changed in a custom
`time_zone.rb` initializer.

```ruby
# Set Time.zone default to the specified zone and make Active Record
# auto-convert to this zone.
# Run "rake -D time" for a list of tasks for finding time zone names.
config.time_zone = 'Central Time (US & Canada)'
```

You can also run `rake time:zones:all` will list all that Rails knows about.

## Localization

Locale behavior is covered in the [All About Helpers chapter][all-about-helpers],
in the TranslationHelper and I18n API sections.

The default is `:en` and you can override both it and your locale files in an
initializer.

```ruby
config.i18n.default_locale = :de
config.i18n.load_path += Dir[Rails.root.join('config','sprechen','*.{rb,yml}')]
```

## Generator Default Settings

Rails generator scripts make certain assumptions about your tool chain. Setting
the correct values here means having to type fewer params on the command line.
For instance, to use RSpec without fixtures and Haml as the template engine, we'd
do the following:


```ruby
# Configure generators values. Many other options are available,
# be sure to check the documentation.
config.generators do |g|
  g.template_engine :haml
  g.test_framework :rspec, fixture: false
end
```

**Note:** Rubygems such as `rspec-rails` and `factory_girl_rails` handle this
particular config for you automatically.

## Load Path Modifications

By default, Rails looks for code in a number of standard directories, including
all nested directories under `app`, such as `app/models`. This is referred to
collectively as the load path. It's exceedingly rare to need to do so, but it is
possible to add other directories to the load path using the following code:

```ruby
# Custom directories with classes and modules you want to be autoloadable
config.autoload_paths += %W(#{config.root}/extras)
```

## Log-Level Override

The default log level is `:debug`, and you can override this:

```ruby
# Force all environments to use the same logger level
# (by default production uses :info, the others :debug)
config.log_level = :debug
```

## Schema Dumper

Every time you run tests, Rails dumps the schema of your development db and
copies it to the test db using an auto-generated `schema.rb` script. It looks
very similar to an Active Record migration script; it actually uses the same API.

You might find it necessary to revert to the older style of dumping the schema
using SQL, if you're doing things that are incompatible with the schema dumper
code (see the comment):

```ruby
# Use SQL instead of Active Record's schema dumper when creating the
# test database. This is necessary if your schema can't be completely
# dumped by the schema dumper, for example, if you have constraints
# or db-specific column types
config.active_record.schema_format = :sql
```

## Console

It's possible to supply a block to `console` to be evaluated when the Rails env
is loaded via the terminal. This enables you to set console-specific configs.
You can save some typing with helper methods like this:

```ruby
console do
  def obie
    User.where(email: "obiefernandez@gmail.com").first
  end
end
```

[&lt;&lt; Default Initializers](ch11-default-initializers.md) | [README](README.md) | [Spring Application Preloader &gt;&gt;](ch13-spring-application-preloader.md)

[all-about-helpers]: ch120-all-about-helpers.md

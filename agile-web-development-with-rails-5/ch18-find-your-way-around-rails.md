[&lt;&lt; Back to the README](README.md)

# Chapter 18. Find Your Way Around Rails

This will cover directory structures, configuration, and environments.

## Where Things Go

- `app/` is where the model, view, and controller files belong.
- `bin/` is for wrapper scripts.
- `config/` is for configuration and database connection parameters.
- `config.ru` is the Rack server configuration file.
- `db/` is for schema and migration information.
- `Gemfile` is for gem dependencies.
- `lib/` is for shared code.
- `log/` is for log files produced by the app.
- `public` is a web-accessible direction, where your app runs from.
- `Rakefile` is a build script.
- `README.md` is for installation and usage documention.
- `test/` is for unit, functional, and integration tests, fixtures, and mocks.
- `tmp/` is for runtime temporary files.
- `vendor/` is for imported code.

So let's ogo through the top-level files:

- `config.ru` configures the Rack Webserver Interface, either to create Rails
  Metal apps, or to use Rack Middlewares in your Rails App.
- `Gemfile` specifies the dependencies of your Rails app. This file isn't used
  by rails, but by your app. You'll see calls to Bundler in the
  `config/application.rb` and `config/boot.rb` files.
- `Gemfile.lock` records the specific versions for each of your Rails app's
  dependencies, and is maintained by Bundler. _Please make sure you check
  this into your repository._
- `Rakefile` defines tasks to run tests, create documentation, extract the
  current structure of your schema, and more. Type `rake -T` at a prompt for
  the full list. Type `rake -D task` to see a more complete description of a
  specific task.
- `README.md` contains general info about the Rails framework.

Now, let's go through the directories (in no particular order).

## A Place for Our Application



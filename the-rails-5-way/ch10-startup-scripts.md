[&lt;&lt; Back to the README](README.md)

# Chapter 10. Startup Scripts

Whenever you start a process to handle requests with Rails (like `rails server`),
one of the first things that happens is that `config/boot.rb` is loaded.

There are three files involved in setting up the entire Rails stack.

## config/environment.rb

This file loads `application.rb`, and then runs initializer scripts.

```ruby
# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!
```

## config/boot.rb

This file is required by `application.rb` to set up Bundler and load paths for
Rubygems.

```ruby
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)
require 'bundler/setup' # Set up gems listed in the Gemfile.
```

**Note:** Bundler.setup will add all your gems to the Rails load path but won't
actually require them. This is referred to as a "lazy-loading" setup. See
[the Rails Class Loader section][development-mode] for more info.

## config/application.rb

Now we get into the meat of configuration. This script loads the Ruby on Rails
gems and gems for the specified `Rails.env` and configures the app. Changing
these items require a server restart to take effect.

```ruby
require_relative 'boot'
```


[development-mode]: ch14-development-mode.md

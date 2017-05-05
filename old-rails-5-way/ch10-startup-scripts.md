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

Note that the boot script is generated as part of your Rails app, but you don't
usually need to edit it.

Next, the Rails gems are loaded.

```ruby
require 'rails/all'
```

By replacing this line you can easily cherry-pick only the components needed
by your app:

```ruby
# To pick the frameworks you want, remove 'require "rails/all"'
# and list only the framework railties that you want:
#
# require "active_model/railtie"
# require "active_record/railtie"
# require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_view/railtie"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"
```

The main config of our app follows, which gets it own module and class:

```ruby
module TimeAndExpenses
  class Application < Rails::Application
      # Settings in config/environments/* take precedence over those
      # specified here. Application configuration should go into files
      # in config/initializers
      # -- all .rb files in that directory are automatically loaded.
```

**Note:** The creation of a module specifically for your app lays a foundation
for running multiple Rails apps in the same executable Ruby process.

[development-mode]: ch14-development-mode.md

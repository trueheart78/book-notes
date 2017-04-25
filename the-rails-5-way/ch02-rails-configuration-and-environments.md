[&lt;&lt; Back to the README](README.md)

# Chapter 2. Rails Configuration and Environments

*Notes forthcoming*

> [Rails] gained a lot of its focus and appeal beause I didn't try to please
  people who did not share my problems. Differentiating between production and
  development was a very real problem for me, so I solved it the best way that
  I knew how.
  - David Heinemeier Hansson

Rails apps have always been preconfigured with three standard modes of operation

1. development
1. test
1. production

These modes are basically execution environments and have a collection of
associated settings that determine things such as which database to connect to
and whether the classes of your app should be reloaded with each request. Adding
a custom environment is also simple.

The env variable of `RAILS_ENV` holds which environment you are currently in.
It corresponds to an env definition in the `config/environments` folder. Next
it checks `RACK_ENV`, and if neither is found, it defaults to `development`.

## Bundler

[Bundler][bundler] is not Rails specific, but is the preferred way to manage
your app's Rubygem dependencies.

One of the most important things that Bundler does is dependency resolution
on the full list of gems specified in your config, all at once. This differs
from the one-at-a-time dependency resolution employed by Rubygems and previous
versions of Rails, which can (and often did) result exceptions due to library
version incompatibilities.

You should read Yehuda's [blog post on the subject][bundler-how] for an interesting
perspective concerning Bundler's conception.

### Gemfile

The root of your Rails project dir contains a Ruby-based gem manifest file named
simply `Gemfile`, with no extension. This file specifies all dependencies of your
Rails app, including the version of Rails.

Basic usage:

```ruby
gem 'kaminari'
gem 'nokogiri'
```

To load a dependency only in a specific environment, place it in a group block
specifying one or more environment names as symbols:


```ruby
group :development do
  gem 'byebug'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end
```

The `gem` directive takes an optional second argument to describe the version of
the library desrired. Leaving it off results in getting the latest _stable_ version.
To include a release candidate or pre-release gem, you'll need to specify the
version.


```ruby
gem 'nokogiri', '1.5.6'
gem 'pry-rails', '> 0.2.2'
gem 'decent_exposure', '~> 2.0.1'
gem 'draper', '1.0.0.beta6'
```

#### Loading Gems Directly From a Git Repo

Until now, we've been loading gems from [rubygems.org][rubygems], but you can also
specify a gem by its source repo as long as it has a `.gemspec` file in the root
directory. Just add a `:git` option in the call to `gem`.

```ruby
gem 'carrierwave', git: 'git@github.com:carrierwaveuploader/carrierwave.git'
```

If the gem is hosted on GitHub and is public, you can use the `:github` shorthand.

```ruby
gem 'carrierwave', github: 'carrierwaveuploader/carrierwave'
```

Gemspecs with binaries or C extensions are also supported.

```ruby
gem 'nokogiri', git: 'git://github.com/tenderlove/nokogiri.git'
```

If there is no `.gemspec` file at the root of a gem's git repo, you must tell
Bundler which version to use when resolving its dependencies.

```ruby
gem 'deep_merge', '1.0', git: 'git://github.com/peritor/deep_merge.git'
```

It's also possible to specify that a git repo contains multiple `.gemspec` files
and should be treated as a gem source. The following example does just that for
the most common git repo that fits the criteria, the Rails codebase iteself.
(Note: you should never actually need to put the following code in a `Gemfile`
for one of your Rails applications).

```ruby
git 'git://github.com/rails/rails.git'
gem 'railties'
gem 'action_pack'
gem 'active_model'
```

Additionally, you can specify that a git repository should use a particular ref,
branch, or tag as options to the git directive.

```ruby
git 'git://github.com/rails/rails.git',
  ref: '4aded'

git 'git://github.com/rails/rails.git',
  branch: '3-2-stable'

git 'git://github.com/rails/rails.git',
  tag: 'v3.2.11'
```

 Specifying a ref, branch, or tag for a git repo specified inline uses the same
 option sytanx:

```ruby
gem 'nokogiri', git: 'git://github.com/tenderlove/nokogiri.git', ref: '0eec4'
```

#### Loading Gems From the File System

You can use a gem that you're actively developing on your local machine using
the `:path` option.

```ruby
gem 'nokogiri', path: '~/code/nokogiri'
```

### Installing Gems


[bundler]: https://bundler.io/
[bundler-how]: http://yehudakatz.com/2010/04/21/named-gem-environments-and-bundler/
[rubygems]: https://rubygems.org

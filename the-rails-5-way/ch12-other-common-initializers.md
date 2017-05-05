<div>
<div style='float: left'><a href='ch11-default-initializers.md'>&lt;&lt; Default Initializers</a></div>
<div style='float: right'><a href='ch13-spring-application-preloader.md'>Spring Application Preloader &gt;&gt;</a></div>
<div style='float: inline-auto;text-align:center'><a href='README.md'>README</a></div>
<div style="clear: both"></div>
</div>

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

<div>
<div style='float: left'><a href='ch11-default-initializers.md'>&lt;&lt; Default Initializers</a></div>
<div style='float: right'><a href='ch13-spring-application-preloader.md'>Spring Application Preloader &gt;&gt;</a></div>
<div style='float: inline-auto;text-align:center'><a href='README.md'>README</a></div>
<div style="clear: both"></div>
</div>

[all-about-helpers]: ch120-all-about-helpers.md


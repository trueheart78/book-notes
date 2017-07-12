[&lt;&lt; Test Mode](ch15-test-mode.md) | [README](README.md) | [Configuring a Database &gt;&gt;](ch17-configuring-a-database.md)

# Chapter 16. Production Mode

Finally, production mode is what you want your Rails app running in whenever it
is deployed to its hosting env and serving public requests. There are a number of
signifcant ways that production mode differs from other modes, not least of which
is the speed boost you get from not reloading all your application classes for
every request.

See `config/environments/production.rb`.

It includes settings like `cache_classes`, `eager_load`, and many more.

## Assets 

In production mode, assets are by default precompiled by the Asset Pipeline. All
files included in `application.js` and `application.css` asset manifests are
compressed and concatenated into their respective files of the same name, located
in the `public/assets` folder.

If an asset is requested that does not exist in the `public/assets` folder, Rails
will throw an exception. To enable live asset compilation fallback on production,
set `config.assets.compile` to `true`.

The `application.js` and `application.css` manifest files are the only JS/CSS
included during the asset pipeline precompile step. To include add'l assets,
specify them using the following:

```ruby
config.assets.precompile += %w( admin.css )
```

## Asset Hosts

By default, Rails links to assets on the current host in the public folder, but
you can direct Rails to link to assets from a dedicated asset server. The 
`config.action_controller.asset_host` setting is covered in detail in the
[All About Helpers][all-about-helpers] chapter, in the "Using Asset Hosts" section.


[&lt;&lt; Test Mode](ch15-test-mode.md) | [README](README.md) | [Configuring a Database &gt;&gt;](ch17-configuring-a-database.md)

[all-about-helpers]: ch120-all-about-helpers.md#using-asset-hosts

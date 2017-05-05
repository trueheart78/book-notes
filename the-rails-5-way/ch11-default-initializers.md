<div>
<div style='float: left'><a href='ch10-startup-scripts.md'>&lt;&lt; Startup Scripts</a></div>
<div style='float: right'><a href='ch12-other-common-initializers.md'>Other Common Initializers &gt;&gt;</a></div>
<div style='float: inline-auto;text-align:center'><a href='README.md'>README</a></div>
<div style="clear: both"></div>
</div>

# Chapter 11. Default Initializers

The `config/initializers` directory contains a set of default init scripts.
_Remember that you need to restart your server when you modify any of these
files_.

_You can and should_ add configs for your own app by adding your own scripts
to the initializers directory.

## config/initializers/application_controller_renderer.rb

View rendering is covered in depth in the [Action View chapter][action-view].
Rails 5 introduces the `ActionController::Renderer` class as a utility for
rendering arbitray templates' absent controller actions, like rendering a PDF
report in a background job.

Templates are rendered in a context with supplementary data. Like if a view
template needs to create a URL, how will it know the hostname, or whether to
use SSL.

The `application_controller_renderer.rb` script provides a place for setting
those kinds of defaults.

```ruby
# ApplicationController.renderer.defaults.merge!(
#   http_host: 'example.org',
#   https: false
# )
```

## config/initializers/assets.rb

The _Asset Pipeline_ has a number of settings that allow you to customize its
behavior. You can view those in the [Asset Pipeline Configuration][assetpipe].

```ruby
# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
```

## config/initializers/backtrace_silencers.rb

Nobody likes really long exception backtraces. Rails actually gives you a built-in
mechanism for reducing the size of backtraces that contain lines which aren't useful.

It lets you modify the way way that backtraces are shortened. You should never
need to remove all silences during normal application development.

## config/initializers/cookies_serializer.rb

Since browser cookies are simply string-based key-value pairs, then storing
anything other than strings requires serialization. This setting controls how
Rails handles that serialization behavior.

```ruby
# Specify a serializer for the signed and encrypted cookie jars.
# Valid options are :json, :marshal, and :hybrid.
Rails.application.config.action_dispatch.cookies_serializer = :json
```

Note that applications created before Rails 4.1 use Ruby's built-in `Marshal`
class to serialize cookie values. If you are upgrade to Rails 5 and want to
transparently migrate your existing Marshal-serialized cookies into the new
JSON-based format, you can set it to `:hybrid`.

```ruby
Rails.application.config.action_dispatch.cookies_serializer = :hybrid
```

When using either serializer, you should be aware that not all Ruby objects
can be natively serialized as JSON. Like Date and Time objects will be
serialized as strings, and Hashes will have symbolic keys stringified.

## config/initializers/filter_parameter_logging.rb

When a request is made to your application, Rails logs all such details. This
lets you specify what request parameters should be filtered from your log files.

## config/initializers/inflections.rb

Rails has a class named `Inflector` whose job is to transform strings from
singulare to plurals, class names to table names, modulared class names to ones
without, and class names to foreign keys, etc.

The default inflections are kept in a file inside the ActiveSupport gem, 
[inflections.rb][as-inflections].

Most of the time it does a decent job of figuring out the pluralized table name
for a given class, but it's not guaranteed.


```ruby
ActiveSupport::Inflector.pluralize "project"
# => "projects"
ActiveSupport::Inflector.pluralize "virus"
# => "viri"
"pensum".pluralize  # Inflector features are mixed into String by default
# => "pensums"
```

To see the test cases, view the [inflector_test_cases.rb][as-inflection-tests]
file.

## config/initializers/mime_types.rb

Rails supports the standard set of MIME types. If your app needs to response to
other MIME types, you can register them in this initializer.

## config/initializers/new_framework_defaults.rb

This contains migration options that promise to ease the move to Rails 5 from
earlier versions. See the related chapters for more details of these commands.


```ruby
# Enable per-form CSRF tokens. Previous versions had false.
Rails.application.config.action_controller.per_form_csrf_tokens = true

# Enable origin-checking CSRF mitigation. Previous versions had false.
Rails.application.config.action_controller.forgery_protection_origin_check = true

# Make Ruby 2.4 preserve the timezone of the receiver when calling `to_time`.
# Previous versions had false.
ActiveSupport.to_time_preserves_timezone = true

# Require `belongs_to` associations by default. Previous versions had false.
Rails.application.config.active_record.belongs_to_required_by_default = true

# Do not halt callback chains when a callback returns false. Previous versions had true.
ActiveSupport.halt_callback_chains_on_return_false = false

# Configure SSL options to enable HSTS with subdomains. Previous versions had false.
Rails.application.config.ssl_options = { hsts: { subdomains: true } }
```

## config/initializers/session_store.rb

Rails session cookies are encrypted by default using an encrypted cookie store.
This initializer configures the session store of the app.

The session cookies are signed using the `secret_key_base` set in the
`config/secrets.yml` file. You can change that key manualls, or run `rake secret`
to generate a new one automatically.

## config/initializers/wrap_parameters.rb

Introduced in Rails 3.1, this initializer configures your app to work with many
JS frameworks out of the box.

```ruby
# Be sure to restart your server when you modify this file.

# This file contains settings for ActionController::ParamsWrapper which
# is enabled by default.

# Enable parameter wrapping for JSON. You can disable this by setting
# :format to an empty array.
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
  end

# To enable root element in JSON for ActiveRecord objects.
# ActiveSupport.on_load(:active_record) do
#  self.include_root_in_json = true
# end
```

When submitting JSON params to a controller, Rails will _wrap_ the params into
a nested hash, with the controller's name being set as the key, so that the
controller can treat JS clients and HTML forms identically. This ensures the
setting of model attributes from request params is consistent with the Rails
form helper convention.

```json
{"title": "The Rails 5 Way"}
```

If a client submitted the above via JSON to an `ArcticlesController`, Rails would
nest the `params` hash under the key "article".

```json
{"title": "The Rails 5 Way", "article" => {"title": "The Rails 5 Way"}}
```

<div>
<div style='float: left'><a href='ch10-startup-scripts.md'>&lt;&lt; Startup Scripts</a></div>
<div style='float: right'><a href='ch12-other-common-initializers.md'>Other Common Initializers &gt;&gt;</a></div>
<div style='float: inline-auto;text-align:center'><a href='README.md'>README</a></div>
<div style="clear: both"></div>
</div>

[action-view]: ch116-action-view.md
[assetpipe]: ch206-asset-pipeline.md
[as-inflections]: https://github.com/rails/rails/blob/master/activesupport/lib/active_support/inflections.rb
[as-inflection-tests]: https://github.com/rails/rails/blob/master/activesupport/test/inflector_test_cases.rb


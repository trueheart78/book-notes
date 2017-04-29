[&lt;&lt; Back to the README](README.md)

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


## config/initializers/

## config/initializers/

## config/initializers/

## config/initializers/

## config/initializers/

## config/initializers/

[action-view]: ch116-action-view.md
[assetpipe]: ch206-asset-pipeline.md

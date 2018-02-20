[&lt;&lt; Routing](ch20-routing.md) | [README](README.md) | [The routes.rb File &gt;&gt;](ch22-the-routes.rb-file.md)

# Chapter 21. The Two Purposes of Routing

The routing system does two things:

1. Maps requests to controller action methods
1. Enables the dynamic generation of URLs for you to use as arguments to methods
   like `link_to` and `redirect_to`.

Each route specifies a pattern, which will be used both as a template for matching
URLs and as a blueprint for creating them. The pattern can be generated automatically
based on conventions, like REST resources.

A route can also include one or more hardcoded segment keys, in the form of key/value
pairs accessible to controller actions in a hash via the `params` method. `:controller`
and `:action` determine which controller and action gets invoked.

Sample route:

```ruby
get 'recipes/:ingredient' => 'recipes#index'
```

This sample privodes:

* HTTP verb constraining method: `get`
* static string: `recipes`
* slash: `/`
* segment key: `:ingredient`
* controller action mapping: `'recipes#index'`

Routes have a pretty rich syntax. This is far from the most complex and simplest.

[&lt;&lt; Routing](ch20-routing.md) | [README](README.md) | [The routes.rb File &gt;&gt;](ch22-the-routes.rb-file.md)

[&lt;&lt; The Two Purposes of Routing](ch21-the-two-purposes-of-routing.md) | [README](README.md) | [Route Globbing &gt;&gt;](ch23-route-globbing.md)

# Chapter 22. The `routes.rb` File

Routes are defined in `config/routes.rb`. This file is created whenever you
start a new Rails app.


```ruby
Rails.application.routes.draw do
  # For details on the DSL available within this file,
  # see http://guides.rubyonrails.org/routing.html
end
```

The whole file consists of a single call to the method `draw` of `Rails.application.routes`,
which takes a block. This is then evaluated at runtime, inside an instance of the
`ActionDispatch::Routing::Mapper` class.

The routing system has to find a pattern match for a url it's trying to recognize
or a parameters match for a URL it's trying to generate. It does this by going through
the routes in the order in which they are defined. The first match is the one used, and
any subsequent matches are skipped.

**Note:** The router code in Rails 5 is based on work by [Aaron Patterson aka Tenderlove](https://github.com/rails/journey)

## Regular Routes

The basic way is to supply a URL pattern plus a controller class/action method
mapping string with the special `to:` parameter.


```ruby
get 'products/:id', to: 'products#show'
```

Since this is so common, there is a shorthand version:


```ruby
get 'products/:id' => 'products#show'
```

DHH has publicly commented on the design decision behind the shorthand form.

> 1) the pattern we've been using in Rails since the beginning of referencing 
> controllers as lowercase without the "Controller" part in controller: "main" 
> declarations and 2) the Ruby pattern of signaling that you’re talking about an 
> instance method by using #. The influences are even part mixed. Main #index 
> would be more confusing in my mind because it would hint that an object called 
> Main actually existed, which it doesn’t. MainController#index would just be a 
> hassle to type out every time–exactly the same reason we went with controller: 
> "main" versus controller: "MainController". Given these constraints, I think
> "main#index" is by far the best alternative…

**Note** This section is mostly academic. See [Chapter 28 - REST, Resources, and Rails](ch28-rest-resources-and-rails.md) for implementation details.

## Constraining Request Methods

As of Rails 4, it's recommended to limit the HTTP method used to access a route.
If you are using the `match` directive, you can use the `:via` option.


```ruby
match 'products/:id' => 'products#show', via: :get
```

Rails provides a shorthand way of expressing this constraint, by replacing `match`
with the desired HTTP method.

```ruby
get 'products/:id' => 'products#show'
post 'products'    => 'products#create'
```

You can also pass multiple verbs into the `:via` option.


```ruby
match 'products/:id' => 'products#show', via: [:get, :post]
```

Defining a route without specifying an HTTP method will get you a `RuntimeError`
exception.

### The `:any` Method :no_entry_sign:

Matching via `:any` used to match against _any_ HTTP verb. Now, it looks to match
against a non-existent `:any` verb, instead of a `:get`, `:post`, etc.


```ruby
match 'products' => 'products#index', via: :any # doesn't do what it seems like it might
```

## URL Patterns

## Segment Keys

### Spotlight on the `:id` Field

### Optional Segment Keys

### Defining Defaults

## Redirect Routes

## The Format Segment

## Routes as Rack Endpoints

## Accept Header

## Segment Key Constraints

## The Root Route

[&lt;&lt; The Two Purposes of Routing](ch21-the-two-purposes-of-routing.md) | [README](README.md) | [Route Globbing &gt;&gt;](ch23-route-globbing.md)

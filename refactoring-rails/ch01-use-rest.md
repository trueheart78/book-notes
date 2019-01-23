[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Callbacks 🔜][upcoming-chapter]

# Chapter 1. Use REST

Smell: Not having RESTful routes

Fix: follow REST!

A good restful route is `#noun#verb`, like `#users#show`
Bad examples are `#noun#verb_noun`, like `#users#make_admin`

```ruby
resources :users, only: [:show] do
  put :make_admin, on: :member
  put :remove_admin, on: :member
end
```

```ruby
resources :users, only: [:show] do
  resources :admin, only: [:create, :destroy]
end
```

This will also require changing of existing button paths, and the creation of a new
`AdminController`. Then the `UsersController` can have these extra methods removed.

So we promoted the idea of making the user an admin a top-level noun/controller. We also moved to
using the RESTful verbs, `:create` and `:destroy`.

## More Subtle

The `OrdersController` needs some love.

```ruby
resources :orders, only: [:show, update]
```

It introduces methods like `order_was_just_refunded?`, meaning that some functionality
exists where it shouldn't. So we'll promote refund to a first class noun.

```ruby
resources :orders, only: [:show, update] do
  resource :refund, only: [:create]
end
```

Then we'll need a `RefundsController`

Good controllers tend to not have much logic outside of an `if/else` clause. However, a bit
more isn't bad. We could totally have a `Refund` service object, too, that takes an `@order` and 
then can have a `run!` method on it. Then we can write model-focused specs, pulling things
from the old spec we were using and refactor accordingly. 

Also note, our new `Refund` class? Totally not an `ActiveRecord` model.

[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Callbacks 🔜][upcoming-chapter]

[readme]: README.md
[upcoming-chapter]: ch02-callbacks.md

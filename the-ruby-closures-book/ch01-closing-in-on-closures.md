[&lt;&lt; Back to the README](README.md)

# Chapter 1. Closing in on Closures

## Closures Made to Sound Hard

Many of the different technical resources out there make closures sound a lot
harder than they really are.

## Closures Are _Not_ Hard

A closure is a relatively simple concept once you understand _two_ other
concepts: _lexical scoping_ and _free variables_.

## Lexical Scoping: Closest One Wins

> Lexical scoping says that whichever assignment to a variable is _the
  closest_ gets that value.

Lexical scoping is also known as _static scoping_.

## Free Variables

```ruby
message = 'surprise the incontinent.'
100.times do
  prefix = 'I will not'
  puts "#{prefix} #{message}"
end
```

Notice where `message` and `prefix` are defined. The first is declared outside
of the block, but in the _parent scope_.

This is lexical scoping in action.

### Identifying Free Variables

> A free variable is one where it is not declared in that statement, but is
  defined in a parent scope.

We'll modify the above code to use lambdas instead. They are Ruby's version of
anonymous functions.

```ruby
couch_gag = lambda do |message|
  lambda do
    prefix = 'I will not'
    puts "#{prefix} #{message}"
  end
end
```

`couch_gag` is an anonymous function that takes a single argument `message`.
Its return value is _another lambda_. The body of the inner lambda declares
the p`prefix` variable. On the other hand, `message` is not declared anywhere
in the lambda body, but in the _parent scope_, as the lambda argument. That
means that `message` is a _free variable_.

The parent scope is also called the _surrounding lexical scope_, and it is
easy to visualize because the outer lambda wraps around the inner one. It is
this wrapping that allows the innery lambda to access variables declared in
the outer one.

In tis example, the free variables are in UPPERCASE.

```ruby
couch_gag = lambda do |MESSAGE|
  lambda do
    prefix = 'I will not'
    puts "#{prefix} #{MESSAGE}"
  end
end
```

Another example:

```ruby
times_by = lambda do |MULTIPLIER|
  lambda do |x|
    MULTIPLIER * x
  end
end
```

Whenever some inner lambda refers to a variable that is not declared within
it, but that variable is declared in the _parent_ scope of that lambda, then
we can say that the variable is free.

## Closures, Finally!

Surprise! You've already seen them!

```ruby
times_by = lambda do |MULTIPLIER|
  lambda do |x|
    MULTIPLIER * x
  end
end
```

The _inner lambda_ is a closure! A closure has to be a function, and it must
have a reference to a variable in its parent scope.

To sound smart, we can say that the inner lambda _closes over_ `MULTIPLIER`.

```ruby
couch_gag = lambda do |MESSAGE|
  lambda do
    prefix = 'I will not'
    puts "#{prefix} #{MESSAGE}"
  end
end
```

The inner lambda above _closes over_ `MESSAGE`, the free variable.

So, to identify a closure, it is _a function whose body references a free
variable_.

## Doing the Lambda

Lambdas are necessary to closures, so let's spend some time looking at them.

Here is a simple, useless, lambda:

```ruby
l = lambda {}
```

So, let's give it something to do:

```ruby
is_even = lambda { |x| x % 2 == 0 }
```

One way to invoke a lambda is to `call` it:

```ruby
is_even.call 42 #=> true
is_even.call 43 #=> false
```

Now what about `is_odd`? Well, there is the obvious way:

```ruby
is_odd = lambda { |x| x % 2 != 0 }
```

However, there is a way that allows us to use our previously defined `is_even`
lambda:

```ruby
is_odd = lambda { |x| not is_even.call(x) }
```

Turns out, functions such as `is_even` and `is_odd` are called _predicates_.
That is, they answer in a boolean manner when called.

```ruby
drinkable_age = lambda { |x| x > 18 }
undrinkable_age = lambda { |x| not drinkable_age.call(x) }
```

Let's make another lambda to handle the _complements_ we have implemented.

```ruby
complement = lambda { |pred| lambda { |args| not pred.call(args) } }
```

We can use it like this:

```ruby
is_odd = complement.call is_even
undrinkable_age = complement.call drinkable_age
```

The free variable is `pred` while the inner lambda is the closure.

## First-Class Functions

A value is like an integer or string, but a value can also be a function. This
makes it a _first-class_ function, meaning you can assign it to variables,
pass it around as arguments, and return as values.

## Exercises

1. A closure is a function that references a variable declared in a  parent
   scope.
2. `amount` is the free variable.

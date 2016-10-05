[&lt;&lt; Back to the README](README.md)

# Chapter 2. Beautiful Blocks

Blocks are one of the cornerstones of programming in Ruby. You cannot get by
programming Ruby without involving them in some way.

## `yield` and `block_given?`

The `yield` keyword can be uncomfortable, especially if you have any Python
background.

You can, however, substitute `yield(args)` with the `call_the_block_with(args)`
_mentally_. `yield` is a Ruby keyword that calls the block, passing in the
exact same parameters to the block that you give it.

```ruby
def method_that_expects_block_with_two_args
  yield 10, 3
end
```

The above method calls a block that takes two args. What will the block do?
Here's an example:

```ruby
block_sample do |x, y|
  x * y # => 30
end
```

The block params are under our control, and we can do what we like with them.

```ruby
block_sample do |x, y|
  x**y # => 1000
end
```

`yield` assumes you have a block supplied to the method. If you would like the
block to be _optional_, then `block_given?` is your friend.

```ruby
def method_that_expects_block_with_two_args
  yield 10, 3 if block_given?
end
```

### `yield` Semantics

`yield` has some subtleties to be aware of. First, `yield` is a _keyword_, not
a method.

```ruby
> method :puts # => #<Method: Object(Kernel)#puts>
```

`yield`, however:

```ruby
> method :yield
nameError: undefined method yield for class object.
```

Not only is `yield` not a method, it doesn't have _method semantics_, meaning
it doesn't _behave_ like a method. We say that `yield` has _yield_ semantics.

How is calling a block with the `yield` keyword different from calling a
method? In _Argument passing_ and `return`.

### Argument Passing

The `yield` keyword is more tolerant of missing and extra args. Missing args
are set to `nil`, and extra args are silently discarded.

```ruby
def yield_w_wrong_arity
  yield "Hi", "Reader!"
end

yield_w_wrong_arity do |a, b|
  puts "#{a}, #{b}"
end

# => "Hi, Reader!"
```

With fewer args:

```ruby
def yield_w_wrong_arity
  puts yield "Hi"
end

# => "Hi,."
```

`yield` acts kind of like parallel assignment, in that `nils` are assigned to
missing args:

```ruby
a, b = 1 # => 1
b        # => nil
```

You will see more `yield` soon.

## Blocks for Enumeration

Ruby enumeration is so nice :heart:

```ruby
%w(look ma no for loops).each do |x|
  puts x
end
```

The way they enumerate is not the part to be focused on, however, but _how_
these methods are _implemented_.

### Implementing `times`

An example of an enumerator is the `times` method:

```ruby
3.times { puts "yo dog" }
```

From the way `times` is used, it appears that it belongs to the `Fixnum` class.

Notice that the block takes in _no parameters_.

We're going to implement `times` for ourselves. Aslo, we're going to forget,
for now, that `each` doesn't exist.

```ruby
class Fixnum
  def times
  end
end
```

The above makes any call to `times` empty.

So, if we want to reimplement this without `each`, here's one way:

```ruby
class Fixnum
  def times
    x = 0
    while x < self
      x += 1
      yield
    end
    self
  end
end
```

Using `self` allows you to see what the value being checked against actually
is. Doing so, the above code will now yield the expected number of `times`.

### Implementing Each

Let's implement the `each` method in the `Array` class. An example of usage:

```ruby
%w(look ma no for loops).each do |x|
  puts x
end
```

This prints out:

```
look
ma
no
for
loops
```

Here, the block accepts _one_ arg. So, let's reopen `Array`:

```ruby
class Array
  def each
  end
end
```

Basic and useless. So, let's track the iteration using the humble `while` loop:

```ruby
class Array
  def each
    x = 0
    while x < self.length
      yield self[x]
      x += 1
    end
  end
end
```

## Exercises

1. Implementing map using each:

```ruby
class Array
  def map
    result = []
    each { |x| res << yield(x) }
    result
  end
end
```

1. Implementing `String#each_word`:

```ruby
class String
  def each_word
    x = 0
    words = self.split
    while x < words.length
      yield words[x]
      x += 1
    end
  end
end
```

## Managing Resources with Blocks

Blocks are an excellent way to abstract pre and post processing. A wonderful
example is how resource management works. Examples like opening and closing a
file handler, a socket connection, db connection, etc.

In other languages, you really ought not to forget to close your resource when
you are done with it (were you brought up in a virtual barn?).

```ruby
f = File.open 'War and Peace.txt', 'w'
f << 'this book is long'
f << 'oh so long'
f.close
```

If you skip out on `f.close`, the file remain open until the script terminates.
This creates a _resource leak_. A daemon or a web app could eventually open
more resources than the OS can handle, as the limit is finite.

If you think about it, we really just want to write to the file. Closing the
resource can just be a bother.

Here's how Ruby's elegance works:

```ruby
File.open('War and Peace.txt', 'w') do |f|
  f << 'this book is long'
  f << 'oh so long'
end
```

By passing in a block into `File.open`, Ruby takes care of closing the resource
when you are done with the block. Oh yeah, and the file handle is nicely
scoped _within_ the block.

### Implementing `File.open`

From the Ruby stdlib on `File.open`:

> With no associated block, `File.open` is a synonym for `::new`. If the
  optional code block is given, it will be passed the opened file as an
  argument and the File object will automatically be closed when the block
  terminates. The value of the block will be returned from `File.open`.

The tells us _everything_ we need to re-implement `File.open`:

```ruby
class File
  def self.open(name, mode, &block)
    file = new name, mode
    return file unless block_given?
    yield file
  ensure
    file.close
  end
end
```

It's pretty frickin' elegant :heart: And don't overlook the `ensure` that makes
this work even when exceptions are raised from _within_ the passed block.

And because `yield` is the last line, the value of the block will be returned
from `File.open`.

## Making Object Initialization Beautiful

Blocks provide a pretty way to initialize an object. You often see this when
it looks like _applying configuration_ on an object. Spoilers: they usually
mean the same thing.

```ruby
client = Twitter::REST::Client.new do |config|
  config.consumer_key = 'CONSUMER_KEY'
  config.consumer_secret = 'CONSUMER_SECRET'
  config.access_token = 'ACCESS_TOKEN'
  config.access_token_secret = 'ACCESS_SECRET'
end
```

### Implementation

Let's see what it would take to get the above code implemented.

```ruby
module Twitter
  module REST
    class Client
    end
  end
end

client = Twitter::REST::Client.new do |config|
  config.consumer_key = 'CONSUMER_KEY'
  config.consumer_secret = 'CONSUMER_SECRET'
  config.access_token = 'ACCESS_TOKEN'
  config.access_token_secret = 'ACCESS_SECRET'
end
```

This code doesn't do anything, but it also _won't_ produce any errors. **Ruby
ignores the block being passed in when it is not called within the method
body**.

To get it to do _something_, let's see what we know:

1. it is being called from the _initializer_.
1. it accepts a single argument, the `config` object.
1. the config object has some setters.
1. `config` and the instantiated object can be the same thing.

```ruby
module Twitter
  module REST
    class Client
      attr_accessor :consumer_key, :consumer_secret
                    :access_token, :access_token_secret

      def initialize
        yield self if block_given?
      end
    end
  end
end
```

Passing `self` into the `yield` block means that we can call instance methods
from _within_ the block. You can then call the `attr_accessor` methods we
defined. **Eureka!**

What if we'd also to be able to initialize with a hash, and also call a block?
First, we'd iterate through the has of options first, followed by calling the
block:

```ruby
def initialize(options = {}, &block)
  options.each { |k, v| send "#{k}=", v }
  instance_eval(&block) if block_given?
```

_Reader is unsure why `yield` is not used above, as well as why a block is
being defined in the method definition._

## Creating DSLs With Blocks

There is a slight variation to object instantiation. This minor change allows
us to create domain specific languages, or DSLs, in Ruby.

```ruby
routes = Router.new do
  match '/about' => 'home#about'
  match '/users' => 'users#index'
end
```

This setup routes incoming requests to a controller#action initialization, a la
Rails.

What we know:

1. The initializer of the `Router` class takes a block that accepts a single
   argument, the object itself.
1. The `Router` class quite likely has an instance method called `match` that
   takes a hash as an argument.


```ruby
class Router
  def initialize
    yield self
  end

  def match(route)
    puts route
  end
end
```

Now, the challenge is going from this:

```ruby
routes = Router.new do |r|
  r.match '/about' => 'home#about'
  r.match '/users' => 'users#index'
end
```

to this:

```ruby
routes = Router.new do
  match '/about' => 'home#about'
  match '/users' => 'users#index'
end
```

Enter `instance_eval`.

### Using `instance_eval` to Change `self`

When a method is called without a receiver (aka the object), it is assumed the
receiver is `self`. However, a block is not defined within the object, so the
receiver is _the main scope_.

So we can get errors like:

```ruby
in `block in <main>': undefined method `match' for main:Object (NoMethodError)
```

In this case, Ruby is looking for the `match` method in the `main` scope.

### `instance_eval` to the Rescue!

To convince Ruby that the `self` in the call to `match` is the `Router` and not
the `main` object, we use `instance_eval` to evaulate the code in the context
of the instance. In other words, `instance_eval` changes `self` to point to the
instance you tell it to.


```ruby
def initialize(&block)
  instance_eval &block
end
```

**Notice** that the `block` being sent through is actually `&block`. Why?

1. We need the `&block` because we need to explicitly tell Ruby that we are
   _capturing a block_. Ruby internally converts the block into a Proc object.
1. `instance_eval` expects a _block_, so we need to use `&block` to convert the
   Proc into a block.
   
Although confusing, here's a good way to remember it:

> Rule: Block -> Proc if `&block` is in a method argument
> Rule: Proc -> Block if `&block` is in method body 

Most DSLs that have this pattern use `instance_eval` one way or another.

## Blocks are Closures

Closures are a) a function b) whose body references some variable that is
declared in a parent scope.

Well, blocks act like anonymous functions. After all, blocks carry a bunch of
code, to be called only when `yield`ed. A block also carries around the context
in which it was defined.

### Block Local Variables

To declare a _block local variable_, you use a `;` to denote them:

```ruby
def chalkboard_gag(line, repetition)
  repetition.times { |x; line| puts "#{x}: #{line}" }
end
```

The above prints out the `x` indices, but not the `line` the method received.
It prints out a the empty `line` declared inside the block.

Block local variables are a way to ensure that the variables within a block do
not override another _outer_ variable of the same name. Another example:

```ruby
x = 'outside block'
1.times { x = 'inside block' }

puts x # => 'inside block'
```

The outer `x` is modified by the block, because the block _closes ove_ the
outer `x`, and therefore has a reference to it. To prevent it, but keep the
same variable name, we would do this:

```ruby
x = 'outside block'
1.times { |;x| x = 'inside block' }

puts x # => 'outside block'
```

You could alsode just properly name your variables to avoid these collisions,
but at least now you are aware of what can happen if you don't take the scope
into account.

### Block Variables Act Like Parallel Assignments

What values do `a`, `b`, and `c` get assigned?

```ruby
a, *b, c = 1, 2, 3, 4, 5

a # => 1
b # => [2, 3, 4]
c # => 5
```

It is the same story with block variables

```ruby
def block_vars_example
  yield 1, 2, 3, 4, 5
end

block_vars_example do |a, *b, c|
  p a # => 1
  p b # => [2, 3, 4]
  p c # => 5
end
```

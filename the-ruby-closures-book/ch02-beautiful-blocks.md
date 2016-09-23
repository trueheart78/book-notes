[&lt;&lt; Back to the README](README.md)

# Chapter 2. Beautiful Blocks

Blocks are one of the cornerstones of programming in Ruby. You cannot get by
programming Ruby without involving them in some way.

## `yield` and `block_given?`

The `yield` keyword can be uncomfortable, especially if you have any Python
background.

You can, however, substitute `yeild(args)` with the `call_the_block_with(args)`
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

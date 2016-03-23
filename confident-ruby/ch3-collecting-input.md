[&lt;&lt; Back to the README](README.md)

# Chapter 3. Collecting Input

## Introduction to Collecting Input

Some methods might not receive input, but those methods don't usually accomplish
much.

```ruby
def seconds_in_day
  24 * 60 * 60
end
```

That could actually be a constant, though.

```ruby
SECONDS_IN_DAY = 24 * 60 * 60
```

You can use arguments to pass input.

```ruby
def seconds_in_days(num_days)
  num_days * 24 * 60 * 60
end
```

You can see that this can become more and more complex quite quickly.

Any information that comes from outside the method is considered input, even a
class name.

#### Indirect Inputs

A direct input is an input used for its own value. An indirect input occurs
any time we send a message to an object other than `self` in order to use its
return value.

More indirection = more tying to the code around it, and the more likely it is
to break.  This is commonly referred to as the *Law of Demeter*.

If you were to combine one indirect input with another to produce a value, you
can start breeding bugs.

You will also see that this is a common idiom in method writing: an *input-collection
stanza*.

You can generally notice this when you decide to add whitespace between lines in
a method, and that is a smell that you are likely doing too much.

#### From Roles to Objects

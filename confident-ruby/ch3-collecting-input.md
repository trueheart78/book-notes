[&lt;&lt; Back to the README](README.md)

# Chapter 3. Collecting Input

## 3.1 Introduction to Collecting Input

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

Writing a method in terms of roles yields code that tells a clear and straightforward
story.

COllecting input isn't just about finding needed inputs; it's about determining
how lenient to be in accepting many types of input, and about whether to adapt
the method's logic to suit the received collaborator types, or vice-versa.

We are now the **bridge the gap from the objects we have to the roles we need** step.

The strategies we will use:

1. **Coerce** objects into the roles we need them to play.
2. **Reject** unexpected values which cannot play the needed roles.
3. **Substitute** known-good objects for unacceptable inputs.

#### Guard the Borders, not the Hinterlands

Programming defensively in every method is redundant, wasteful of programmer
resources, and resulting code induces maintenance headaches. Some, however, are
best suited for the *borders* of your code. This is where you can vet them, like
customs, or being a good neighbor, where trust is implicit once a checkpoint of
sorts is passed.

## 3.2 Use Built-In Conversion Protocols



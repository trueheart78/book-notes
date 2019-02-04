[&lt;&lt; Back to the README](README.md)

# Chapter 1. Rediscovering Simplicity

When you were new to programming you wrote simple code. You may not have appreciated
it at the time, but this was a great strength. Experience has brought you through
solving many complicated problems using increasingly complex solutions. You know
now that most code will someday change. Complexity seems both natural and inevitable.

Where you once optimized code for _understandability_, you now focus on its
_changeability_. It's less _concrete_ and more _abstract_. Things are harder to
understand in hopes that it will ultimately be easier to maintain.

This is the basic promise of Object-Oriented Design (OOD): that if you are willing
to accept increases in the complexity of your code along _some_ dimensions, you
will be rewarded with decreases in complexity along _others_. OOD doesn't claim
to be free; it merely asserts that its benefits outweigh its costs.

Design decisions ineveitably involve trade-offs. There's always a cost. For
example, if you've duplicated a bit of code in many places, the _Don't Repeat
Yourself_ (DRY) principle tells you to extract the duplicatation. DRY is a great
idea but it doesn't mean that it is free.

As you can see, design choices have costs, and they should only be paid if you
accrue some offsetting benefits. Design is thus about picking the right
abstractions.

However, abstractions are hard, and are easy to get wrong. You can't create the
right abstraction until you fully understand the code, but the existence of the
wrong abstraction may prevent you from ever doing so. So the goal is to **resist
the abstractions until they absolutely insist upon being created**.

This book is about finding the right abstraction.

## Simplifying Code

The code you write should meet two often contradictory goals:

1. It must remain concrete enough to be understood.
1. It must be abstract enough to allow for change.

Code that is 100% concrete might be expressed as a single long procedure full
of `if` statements. Code that is 100% abstract might consist of many classes,
each with one method containing a single line of code.

The best solution lies not at either extreme, but somewhere in the middle.
**There is a sweet spot that represents the perfect compromise between
comprehension and changeability, and it's your job as a programmer to find it.**

This section discusses four different solutions to the "99 Bottles of Beer" problem.
They vary in complexity and thus illustrate different points concrete and abstract.

So now, stop. Do the 99 Bottles exercise now. Then, when complete, come on back.

[Link to 99 Bottles Repo (personal)](https://gist.github.com/trueheart78/d39224ffd61a21021cd152b55d6560f8)

### Incomprehensibly Concise

Here's the first of four different solutions to the "99 Bottles" song.

#### Listing 1.1: Incomprehensibly Concise

```ruby
class Bottles
  def song
    verses(99, 0)
  end

  def verses(hi, lo)
    hi.downto(lo).map {|n| verse(n) }.join("\n")
  end

  def verse(n)
    "#{n == 0 ? 'No more' : n} bottle#{'s' if n != 1}" +
    " of beer on the wall, " +
    "#{n == 0 ? 'no more' : n} bottle#{'s' if n != 1} of beer.\n" +
    "#{n > 0  ? "Take #{n > 1 ? 'one' : 'it'} down and pass it around"
              : "Go to the store and buy some more"}, " +
    "#{n-1 < 0 ? 99 : n-1 == 0 ? 'no more' : n-1} bottle#{'s' if n-1 != 1}"+
    " of beer on the wall.\n"
  end
end
```

This first solution embeds a great deal of logic into the verse string. The code above
performs a neat trick: it manages to be concise to the point of incomprehension while also
containing a lot of duplication. It's hard to understand because of its inconsistent and
duplicative nature, and because it has hidden concepts it does not name.

##### Consistency

The style of the conditionals is inconsistent. Most use the _ternary_ form:

```ruby
n == 0 ? 'No more' : n
```

Other statements are made conditional using trailing `if` statements.

```ruby
's' if n != 1
```

Finally, there is the ternary within a ternary on line 16, which is best left without
comment:


```ruby
n-1 < 0 ? 99 : n-1 == 0 ? 'no more' : n-1
```

Every time the style of the conditionals change, the reader has to mentally reset and start looking
at it with new eyes. Inconsistent styling makes code harder for humans to parse; it raises costs
without providing benefits.

##### Duplication

The code duplicates both data _and_ logic. Having multiple copies of the strings `"of beer"` and
`"on the wall"` isn't great, but at least _string_ duplication is easy to see and understand.
Logic, however, is harder to comprehend than data, and the duplicated logic is doubly so. Of
course, if you want to achieve maximum confusion, you can interpolate duplicated logic _inside_
strings, as does the `verse` method above.

Look at these fun pluralization checks:

```ruby
's' if n != 1   # lines 11 and 13
's' if n-1 != 1 # line 16
```

Duplication of logic suggests that there are concepts hidden in the code that are not yet
visible because they haven't been isolated and named. They need to sometimes say `"bottle"` and
`"bottles"` _means something_, and the need to sometimes use `n` and other times `n-1` _means
something else_. The code gives no clue about what these meanings might be; you're on your own.

##### Names

The most obvious point to be made about the names in the `verse` method of this set if code is that
there aren't any. It's all embedded logic.

This code would be easier to understand if it did not place that burden on you. The logic that is
hidden inside the verse string should be dispersed into _methods_, and `verse` should fill itself
with values by sending _messages_.

See [Terminology: Method versus Message][method vs message] for a breakdown in usage.

Creating a method requires identifying the code you'd like to extract and decidint on a method
name. This requiers naming the concept, and names are hard. In the above case, it's very hard. The
code not only contains many hidden concepts, but those are mixed, conflated, as such that their
individual naturaes are obscured. Combining many ideas into a small section of code makes it hard to
isolated and name any single concept.

When you first write a piece of code, you obviously know what it does. 



[method vs message]: method-vs-message.md

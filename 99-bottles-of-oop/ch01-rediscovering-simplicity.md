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

[Link to 99 Bottles Repo (personal)][my github code]

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

When you first write a piece of code, you obviously know what it does. Therefore, during initial dev
the price you pay for poor names is quite low. However, code is read many more times than it is ever
written, and the ultimate cost is often very high and paid for by someone else. Writing code is
likewriting a book, your efforts are for _other_ readers. Yes, good names can be very hard, but
the effort is worth it if you want your work to survive. Code clarity is built upon names.

Problems with consistency, duplication and naming conspire to make the code in 
[Listing 1.1: Incomprehensibly Concise][listing 1.1] costly.

The above opinion is certainly unsupported. The best way to judge code would be to compare its value
to its cost, but that can be hard to gather good data on. Judgements about code are therefore
reduced to individual opinion, and humans are not always in accord. [Judging Code](#judging-code)
will assist (later in this chapter), suggesting ways to acquire empirical data about the _goodness_
of code.

Independent of all judgement about how well a bit of code is arranged, code is also charged with
doing what it's supposed to do _now_ as well as being easy to alter that it can do more _later_.
While it's difficult to get exact figures for value and cost, asking the following questions will
provide insight into the potential expense of a bit of code:

1. How difficult was it to write?
2. How hard is it to understand?
3. How expensive will it be to change?

Notice the first question is a reflection, and the third a prediction. While those might not always
apply, the second is a present concern. The very act of looking at a piece of code declares that you
wish to understand it _at this moment_.

Code is easy to understand when it reflects the problem it's solving, and thus openly exposes that
problem's domain. If [Listing 1.1: Incomprehensibly Concise][listing 1.1] openly exposed the "99
Bottles" domain, a brief glance at the code would answer these questions:

1. How many verse variants are there?
2. Which verses are most alike? In what way?
3. Which verses are most different, and in what way?
4. What is the rule to determine which verse comes next?

These questions reflect core concepts of the problem, yet none of their answers are apparent in
this solution. The number of variants, the difference between the variants, and the algorithm for
looping are distressingly obscure. The code does note reflect its domain, and therefore you can
infer it was difficult to write and will be a challenge to change. If you had to characterize the
goal of the writer of [Listing 1.1: Incomprehensibly Concise][listing 1.1], you may suggest their
highest priority was brevity. Brevity may be the soul of wit, but it quickly becomes tedious in 
code.

### Speculatively General

The next solution errs in a different direction. It does many things well but can't resist
indulging in unnecessary complexity.

#### Listing 1.2: Speculatively General

```ruby
class Bottles
  NoMore = lambda do |verse|
    "No more bottles of beer on the wall, " +
    "no more bottles of beer.\n" +
    "Go to the store and buy some more, " +
    "99 bottles of beer on the wall.\n"
  end

  LastOne = lambda do |verse|
    "1 bottle of beer on the wall, " +
    "1 bottle of beer.\n" +
    "Take it down and pass it around, " +
    "no more bottles of beer on the wall.\n"
  end

  Penultimate = lambda do |verse|
    "2 bottles of beer on the wall, " +
    "2 bottles of beer.\n" +
    "Take one down and pass it around, " +
    "1 bottle of beer on the wall.\n"
  end

  Default = lambda do |verse|
    "#{verse.number} bottles of beer on the wall, " +
    "#{verse.number} bottles of beer.\n" +
    "Take one down and pass it around, " +
    "#{verse.number - 1} bottles of beer on the wall.\n"
  end

  def song
    verses(99, 0)
  end

  def verses(finish, start)
    (finish).downto(start).map {|verse_number|
      verse(verse_number) }.join("\n")
  end

  def verse(number)
    verse_for(number).text
  end

  def verse_for(number)
    case number
    when 0 then Verse.new(number, &NoMore)
    when 1 then Verse.new(number, &LastOne)
    when 2 then Verse.new(number, &Penultimate)
    else        Verse.new(number, &Default)
    end
  end
end

class Verse
  attr_reader :number
  def initialize(number, &lyrics)
    @number = number
    @lyrics = lyrics
  end

  def text
    @lyrics.call self
  end
end
```

If you find this code unclear, you're not alone. It's confusing enough to warrant an explanation but
the explanation naturally reflects the code, it's confusing as well. Don't worry if the following
paragraphs also muddy the water. The goal is help you appreciate the complexity rather than
understand the details.

The code above defines four lambdas and saves them as constants (`NoMore`, `LastOne`, `Penultimate`,
and `Default`). Notice that they each take an argument `verse` but only `Default` actually refers to
it. The code then defines the `song` and `verses` methods. Then comes the `verse` method, which
passes the current verse number to `verse_for` and sends `text` to the result. This is the line of
code that returns the correct string for a verse of the song.

Things get more interesting in `verse_for`, but let's look ahead to the `Verse` class. `Verse`
instances are initialized with two args, `number` and `&lyrics`, and they respond to two messages,
`number` and `text`. The `number` method simply returns the verse number that was passed during
initialization. The `text` method is more complicated; it sends `call` to `lyrics`, passing `self`
as an arg.

If you now return to `verse_for`, you can see that when instances of `Verse` are created, the
`number` arg is a verse number and the `&lyrics` arg is one of the lambdas. The `verse_for` method
gets invoked for every verse of the song, and therefore, you will have one hundred instances of
`Verse` that will be created, each containing a verse number and the lambda that corresponds to that
number.

To summarize, sending `verse(number)` to an instance of `Bottles` invokes `verse_for(number)`, which
uses the value of `number` to select the correct lambda on which to create an instance of `Verse`.
The `verse` method then sends `text` to the returned `Verse`, which in turn sends `call` to the
lambda, passing `self` as an arg. This invokes the lambda, which may or may not actually use the
arg. Regardless, executing the lambda returns a string that contains the lyrics for one verse of the
song.

You can be forgiven if you suspect this is unduly complicated. It is. However, it's curious that
despite this complexity, [Listing 1.2: Speculatively General][listing 1.2] does a much better job 
than [Listing 1.1: Incomprehensibly Concise][listing 1.1] of answering the domain questions.

1. How many verse variants are there?
   - There are 4
2. Which verses are most alike? In what way?
   - Verses 3-99 are most alike, evidenced by the fact that those are all produced by the `Default`
     variant.
3. Which verses are most different? In what way?
   - Verses 0, 1 and 2 are, but it's not obvious. 
4. What is the rule to determine which verse should be sung next?
   - Buried deep within the `NoMore` lambda is a hard-coded "99", which might cause one to infer
     that verse 99 follows verse 0.

This solution's answers to the first three questions above are quite an imporovement over those of
[Listing 1.1: Incomprehensibly Concise][listing 1.1]. Not everything is perfect, as we look at the
value/cost questions:

1. How difficult was it to write?
   - There's far more code here than is needed to pass the tests. This unnecessary code took time to
     write.
2. How hard is it to understand?
   - The many levels of indirection are confusing. Their existence implieces necessity, but you
     could study this code for a long time with discerning why they are needed.
3. How expensive will it be to change?
   - The mere fact that indirection exists suggests that it's important. You may feel compelled to
     understand its purpose before making changes.

As you can see, this solution does a good job of exposing core concepts, but a bad job of being
worth the cost. This good job/bad job divide reflects a fundamental fissure in the code.

Aside from the `song` and `verses` methods, the code does two basic things. It defines a template
for each kind of verse, and it chooses the appropriate template for a specific verse number and
renders that verse's lyrics.

Notice that the verse template contains all the info needed to answer the domain questions. There
are four templates and therefore, there must be four verse variants. The `Default` template
handles 3 through 99, so these verses are clearly most alike. VErses 0, 1, and 2 have their own
special templates, so each must be unique. The four templates are straightforward, which makes
answering the domain questions easy.

However, it's not the templates that are costly, it's the code that chooses a template and renders
the lyrics for a verse. This choosing/rending code is overly complicated, and while complexity is
not forbidden, it _is_ required to pay its own way. Here, however, it does not.

Insteaed of 1) defining a lambda to hold a template, 2) creating a new object to hold the lambda,
and 3) invoking the lambda with `self` as an argument, the code could merely have put each of the
four templates into a method then used the case statements to invoke the correct one. Neither the
lambdas nor the `Verse` class are needed, and the route between them is a series of pointless jumps
through needless hoops.

Given the obvious superiority of this alternative implementation, how on earth did the _"calling a
lambda"_ variant come about? At this remove, it's difficult to be certain of the motivation, but the
code gives the impression that its author feared that the logic for selecting or invokling a
template would someday need to change, and so added levels of indirecation in a misguided attempt to
protect against that day.

They did not succeed. Relative to the alternative, [Listing 1.2: Speculatively General][listing 1.2]
is harder to understand without being easier to change. The additional complexity does not pay off.
The auther may have acted with the best of intentions, but somewhere along the way, their commitment
to the plan overcame good sense.

Programmers tend to love clever code. It's like a neat card trick that uses sleight of hand and
misdirection to make magic. Writing it, or suddenly understanding it, supplies a little burst of
appreciative pleasure. However, this pleasure distracts the eye and seduces the mind, and allows
cleverness to worm its way into inappropriate places.

You must resist being clever for its own sake. If you are capable of conceiving and implementing a
solution complex as [Listing 1.2: Speculatively General][listing 1.2], it is incumbent upon you to
accep the _harder_ task and write simpler code.

Neither [Listing 1.2: Speculatively General][listing 1.2] nor [Listing 1.1: Incomprehensibly
Concise][listing 1.1] is the best solution for "99 Bottles". Perhaps, as was true for porridge, the
third solution will be _just right_.

### Concretely Abstract

Let's attempt to name the concepts in the domain.

#### Listing 1.3: Concretely Abstract

```ruby
class Bottles
  def song
    verses(99, 0)
  end

  def verses(bottles_at_start, bottles_at_end)
    bottles_at_start.downto(bottles_at_end).map do |bottles|
      verse(bottles)
    end.join("\n")
  end

  def verse(bottles)
    Round.new(bottles).to_s
  end
end

class Round
  attr_reader :bottles
  def initialize(bottles)
    @bottles = bottles
  end

  def to_s
    challenge + response
  end

  def challenge
    bottles_of_beer.capitalize + " " + on_wall + ", " +
    bottles_of_beer + ".\n"
  end

  def response
    go_to_the_store_or_take_one_down + ", " +
    bottles_of_beer + " " + on_wall + ".\n"
  end

  def bottles_of_beer
    "#{anglicized_bottle_count} #{pluralized_bottle_form} of #{beer}"
  end

  def beer
    "beer"
  end

  def on_wall
    "on the wall"
  end

  def pluralized_bottle_form
    last_beer? ? "bottle" : "bottles"
  end

  def anglicized_bottle_count
    all_out? ? "no more" : bottles.to_s
  end

  def go_to_the_store_or_take_one_down
    if all_out?
      @bottles = 99
      buy_new_beer
    else
      lyrics = drink_beer
      @bottles -= 1
      lyrics
    end
  end

  def buy_new_beer
    "Go to the store and buy some more"
  end

  def drink_beer
    "Take #{it_or_one} down and pass it around"
  end

  def it_or_one
    last_beer? ? "it" : "one"
  end

  def all_out?
    bottles.zero?
  end

  def last_beer?
    bottles == 1
  end
end
```

This solution is characterized by having many small methods. Often, that's a good thing, but in this
case, it's gone horribly wrong. Let's see how this solution does on the domain questions:

1. How many verse variants are there?
   - It's almost impossible to tell.
2. Which verses are most alike? In what way?
   - Ditto.
3. Which verses are different? In what way?
   - Ditto.
4. What is the rule to determine which verse should be sung next?
   - Ditto.

It fares no better on the value/cost questions.

1. How difficult was it to write?
   - Difficult. It took a lot of thought and time.
2. How hard is it to understand?
   - The individual methods are easy to understand, but despite this, its tough to get a sense of
     the entire sone. The parts don't seem to add up to the whole.
3. How expensive will it be to change?
   - While changing the code inside any single method is cheap, it's difficult to tell how it
     cascades.

It's obvious the author of this code was committed ti doing the right thing, following the _Red,
Green, Refactor_ style of writing code. The various strings that make up the song are never repeated
-- it looks as though these strings were refactored into separate methods at the first sign of
duplication.




[method vs message]: method-vs-message.md
[my github code]: https://github.com/trueheart78/99-bottles-of-oop
[listing 1.1]: #listing-11-incomprehensibly-concise
[listing 1.2]: #listing-12-speculatively-general
[listing 1.3]: #listing-13-concretely-abstract

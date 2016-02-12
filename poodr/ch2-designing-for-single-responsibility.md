[&lt;&lt; Back to the README](README.md)

# Chapter 2. Designing Classes with a Single Responsibility

The foundation of an OO system is the **message**, but the most visible structure
is the **class**. Messages are at the core of design.

So many questions about design can seem eternal. Instead, the first obligation is
to take a deep breath and **insist that it be simple**. Your goal is to model your
application, using classes, such that it does what it is supposed to do **right now**
and is also easy to change **later**.

Thankfully, a lot has been figured out for you. Thought and research has gone into
identifying the qualities that make an app easy to change. The techniques are simple;
you only need to know what they are and how to use them.

## Deciding What Belongs in a Class

Technical knowledge isn't the hurdle here, but organizational.

### Grouping Methods into Classes

You are constructing a box that is difficult to think outside of. (No pressure)

You cannot get it right at the beginning.

Design is more the art of preserving changeability than it is the act of achieving
perfection.

### Organizing Code to Allow for Easy Changes

Asserting that code should be easy to change is akin to stating should be polite;
the statement is impossible to disagree with yet it in no way helps a parent raise
an agreeable child.

Easy to change 

+ Changes have no unexpected side-effects
+ Small changes in requirements require correspondingly small changes in code
+ Existing code is easy to reuse
+ The easiest way to make a change is to add code that is itself easy to change

So, here's your list

- *Transparent* The consequences of change should be obvious in the code that is
changing and in distant code that relies upon it.
- *Reasonable* The cost of any change should be proportional to the benefits the
change achieves.
- *Usable* Existing code should be usable in new and unexpected contexts.
- *Exemplary* The code itself should encourage those who change it to perpetuate
these qualities.

Code that is *T.R.U.E* not only meets today's needs but can also be change to meet
the needs of the future.

## Creating Classes That Have a Single Responsibility

A class should do the smallest possible useful thing; it should have a single
responsibility. 

### Why Single Responsibility Matters

Apps that are easy to change consist of classes that are easy to reuse.

A class that has more than one responsibility is difficult to reuse. The various
responsibilities are likely thoroughly entangled within the class.

If the responsibilities are so coupled that you cannot use the bahvior you need,
you could duplicate the code of interest (a terrible idea). It creates add'l
maintenance and increases bugs.

Because the class you're reusing is confused about what it does and contains
several tangled up responsbilities, it has many reasons to change.

#### Determining If a Class Has a Single Responsibility

You do not know what feature requests will arrive in the future. Don't waste time
between choices that are likely both wrong, yet plausabile.

*Do not feel compelled to make design decisions prematurely. Resist, even if you
fear your code would dismay the design gurus.* When face with an imperfect and
muddled class, ask yourself: *"What is the future cost of doing nothing today?"*

**When the future cost of doing nothing is the same as the current cost, postpone
the decision. Make the decision only when you must with the info you have at that
time.**

The structure of every class is a message to future maintainers of the app. It
reveals your design intentions. **For better or for worse, the patterns you establish
today will be replicated forever.**

There is an "improve it now" vs "improve it later" tension, which always exists. 
Apps are never prefectly designed. Every choice has a price. Make informed tradeoffs.

## Writing Code That Embraces Change

Because change is inevitable, coding in a changeable style has big future payoffs.
Bonus is that coding in these styles will improve your code today, at no extra cost.

### Depend on Behavior, Not Data

Behavior is captured in methods and invoked by sending messages.  DRY code
tolerates change because any change in behavior can be made by chaning code in
just once place.

Objects also often contain data, held in an instance variable. Always access the
data using accessor methods.

#### Hide Instance Variables

Hide the variables, even from the class that defines them, by wrapping them in
methods. `attr_reader`, `attr_accessor` help.

Implementing a wrapper method changes it from data (referenced all over) to
behavior (defined once). Now if the var is referred to 10 times and it needs to
change, you change the method once.

Dealing with data as if it's an object that understands messages introduces
two new issues: visibility and the line between data and behavior disappearing.

You should always err on the side of hiding data from yourself, as it protects
the code from being affected by unexpected changes.

#### Hide Data Structures

If it depends on the data's structure (think an array with items at certain
positions), if that structure changes, then that code must also change. An array
with references to its structure will create leaky references, where the structure
is accessed all over.

Not DRY :-1:

Imagine if this was an array of hashes...

**Direct references into complicated structures are confusing, because they
obscure what the data really is, and they are a maintenance nightmare, as every
reference will need to be changed if the array structure changes.**

Consider using the `Struct` class to help in these instances. *"[a struct] is
a convenient way to bundle a number of attributes together, using accessor methods,
without having to write an explicit class."* 

If you can control the input, pass in a useful object, but if you are compelled
to take a messy structure, hide the mess even from yourself.

### Enforce Single Responsibility Everywhere

#### Extract Extra Responsibilities from Methods

Methods, like classes, should have a single responsibility. All the same reasons
apply; having just one responsibility makes them easy to change and easy to reuse.
All the same design techniques work; **ask them questions about what they do and try
ti describe their respobilities in a single sentence.**

Separating interation from the action that's being performed on each element is a
common case of multiple responsibility that is easy to recognize.

**You do not have to know where you're going to use good design practices to get
there.**

**Good practices reveal design.**

Methods that have a single responsibility confer the following benefits:

+ Expose previously hidden qualities
+ Avoid the need for comments. A comment is a sign that an extraction should happen.
+ Encourage reuse.
+ Are easy to move to another class.

#### Isolate Extra Responsibilities in Classes

Once every method has a single responsibility, the scope of your class will be 
more apparent.

Your goal is to preserve single responsibility in your class while making the
fewest design commitments possible. Postpone decisions until you are forced to
make them. Don't decide; preserve your ability to make a decision *later*.

You can embed structs inside of classes.

```ruby
class Gear

  def initialize
  end

  Wheel = Struct.new(:rim, :tire) do
    def diameter
    end
  end
end
```

This helps keep the idea that a wheel only exist in the context of Gear.

If you have a muddled class with too many responsibilites, separate them into
different classes. Concentrate on the primary class. Decide what it should do
and enforce your decision fiercely. hen isolate extra responsibilities that
you can't remove yet. **Do not allow extraneous responsibilities to leak into
your class.**

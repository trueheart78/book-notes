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

### Organizing Code to ALlow for Easy Changes

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



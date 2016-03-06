[&lt;&lt; Back to the README](README.md)

*Pulled from the end of Chapter 8, "Combining Objects with Composition"*

# Choosing Relationships

The trick to lowering your application costs is to apply each technique to the
right problem. 

- "Inhertiance is specialization."
- "Inheritance is best suited to adding functionality to existing classes when
   you will use most of the old code and add relatively small amounts of new
   code."
- "Use composition when the behavior is more than the sum of its parts."

## Use Inheritance for is-a Relationships

Small sets of real-world objects that fall naturally into static, transparently
obvious specialization hierarchies are candidates to be modeled using classical
inheritance.

If you have  six different shocks, almost all identical, you can see that each
is-a shock.

If modeling a bevy of new shocks requires dramatically expanding the hierarchy,
or if the new shocks don't conveniently fit into the existing code, reconsider
alternatives **at that time.**

## Use Duck Types for behaves-like-a Relationships

For problems that require many different objects to play a common role, duck
types are the likely candidate. For *scheduable, preparable, printable, etc*.

A bicycle **behaves-like-a** scheduable but it **is-a bicycle**. Also, the need
is widespread; many otherwise unrelated objects share a desire to play the same
role.

Think about roles from the outside. The holder of a *schedulable* expects it to
implement `Schedulable`'s interface and to honor `Schedulable`'s contract. All
*schedulabless* are alike in that they must meet these expectations.

You need to recognize that a role exists, define the interface of its duck type
and provide an implementation of that interface for every possible player. Some
roles consist only of their interface, others share common behavior. Define the
common behavior in a Ruby module to allow objects to play the role without
duplicating the code.

## Use Composition for has-a Relationships

Many objects contain numerous parts but are more than the sum of those parts.
`Bicycles` **have-a** `Parts`, but the bike itself is something more. Given
the current requirements of the bicycle example, the most cost-effective way to
model the `Bicycle` object is via composition.

This **is-a** versus **has-a** distinction is at the core of deciding between
inheritance and composition. The more parts an object has, the more likely it
should be modeled with composition. For every problem, assess the costs and
benefits of alternative design techniques and use your judgement and experience
to make the best choice.

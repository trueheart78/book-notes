[&lt;&lt; Back to the README](README.md)

# Chapter 1. Object-Oriented Design

The world is procedural. Producral software fits these activities.

The world is also object-oriented. Each of the objects you interact with comes
equipped with its own behavior. Some predictable, others not so much.

This book is about designing object-oriented software, and it views the world
as a seriers of spontaneous interactions between objects. OOD requires that
you shift from thinking of the world as a collection of predefined procedures
to modeling the world as a series of messages that pass between objects.

Immerse yourself in objects.

## In Praise of design

If painful programming were the most cost-effective way to produce working
software, programmers would be morally obligated to suffer stoically or to
find other jobs.

The techniques of OOD solve both the moral and technical dilemmas of programming:
following them produces cost-effective software using code that is also a
pleasure to work on.

### The Problem Design Solves

OOD does not matter if the application never needs to change. (ha!) Unfortunately,
something **will** change. It always does.

Changing requirements are the programming equivlent of friction and gravity. They
introduce forces that apply sudden and unexpected pressure that work against the
best-laid plans. *It is the need for change that makes OOD matter.*

Applications that are easy to change are a pleasure to write and a joy to extend.
They're flexible and adaptable. The opposite are expensive to change. The worst
of them gradually become personal horro films.

### Why Change Is Hard

Object-oriented applications are made up of parts that interact to produce the
behavior of the whole. The parts are *objects*; the interactions are embodied
in the *messages* that pass between them. Getting the right message to the
correct target object requires that the sender know things of the receiver.
This knowledge bcreates dependencies that stands in the way of change.

OOD is about *managing dependencies*. It is a set of coding techniques that
arrange dependencies such that objects can tolerate change. Bad or no design
means unmanaged dependencies that wreak havoc because of objects that know too
much about one another. Changing one object causes a ripple effect that can
force change upon its collaborators.

Objects that know too much have man expectations. They're picky.

In a small application, poor design is survivable. The problem with poorly
designed small applications is that they grow up to be poorly designed big
apps.

### A Practical Definition of Design

Every app is a collection of code; the code's arrangement is *design*. Design
is not an assembly line where trained workers construct identical widgets;
it's a studio where like-minded artists sculpt custom apps. *Design is thus an
art, the art of arranging code*.

Part of the difficulty of design is that every problem has two components. You
have to write code for today's feature, as well as create code that is amenable
to being changed later.

Design principles overlap and every problem has a shifting timefram, so design
challenges can have endless solutions.

You must combine an overall understanding of your app's requirements with knowledge
of the costs and benefits of design alternatives and then arrange code that is
cost effective in the present **and** in the future.

Programmers are not psychics. *Practical design does not anticipate what will
happen to your app, only that something will. It doesn't guess the future; it
preserves your options for accomodating the future. It leaves you room to move.*

The purpose of design is to allow you to do design **later** and its primary
goal is to reduce the cost of change.

## The Tools of Design

Design is not the act of following a fixed set of rules, but a journey where
earlier choices close off some options and open access to others.

Principles and patters are our tools.

### Design Principles

The *SOLID* acronym is 5 of the most well known OOD principles.

+ *S*ingle Responsibility.
+ *O*pen-Closed.
+ *L*Iskov Substitution.
+ *I*nterface Segregation.
+ *D*ependency Inversion.

Other principles:

+ *DRY*: Don't Repeat Yourself
+ *Law of Demeter*

The principles of good design represent measurable truths and following them
to improve your code.

### Design Patterns

Design patterns are "simple and elegant solutions to specific problems in object-
oriented software design" that you can use to "make your own designs more
flexible, modular, reusable and understandable."

They sound incredibly powerful. To name common problems and solve them in common
ways.

Each well-known pattern is a near perfect open-source solution for the problem
it solves.

Zealous use, however, is to be avoided. Pattern misapplication results in
complicated and confusing code. So be a good user and don't misuse your tools.

This book will prepare you to understand these patterns and give you the
knowledge to choose and use them appropriately.

## The Act of Design

Common principles and patterns still make designing object-oriented software
hard. Apps come into existence because some programmer applied the tools,
either making a beautiful cabinet or a rickety chair.

### How Design Fails

First way design fails is due to a lack of it.

A friendly language that doesn't require much expertise can result in apps
built by those without proper OOD. 

Successful but **undesigned** apps carry the seeds of their own destruction:
they are easy to write but gradually become impossible to change. *Past
experience does not predict the future.* Look for: *"Yes, I can add that
feature, but it will break everything.*

More exp'd programmers can fall into overdesign, not knowing much about OOD
application. *Relentless design* has them applying principles and patterns
inappropriately. Castles of code that hem them in by stone walls.
**Look for: "It wasn't designed to do that."** 

OO software fails when the act of design is separated from the act of programming.
Design is a process of progressive discovery that relies on a feedback loop.
This feedback loop should be timely and incremental. Agile FTW. When design is
dictated from afar none of the necessary adjustments can occur and early
failures of understanding get cemented into the code.
**Look for: "I can certainly write this, but it's not what you really want and
you will eventually be sorry."**

## When to Design

Agile believes that your customers can't define the software they want before
seeing it, so logically you should build software in tiny increments,
gradually iterating your way into an app that meets the customer's true needs.

If Agile is correct, that makes two other things true:

1. There is no point in doing a *Big Up Front Design (BUFD)* because it cannot
possibly be correct.
2. No one can predict when the app will be done.

Agile is uncomfortable for some people because it's too loose. A BUFD provides
a feeling of control that Agile does not. But this is an illusion that will not
survive the act of writing the app.

BUFD inevitably leads to an adversarial relationship between customers and
programmers. The programmers are at fault when the project misses the delivery
deadline. If it's on time but doesn't fill the need, the customer gets the
blame. BUFD docs do not produce quality software, only blame for one party.

Agile works because it acknowledges that certainty is unattainable **in advance**
of the applications's existence. You can develop software without knowing
the target nor the timeline.

Note: BUFD != OOD. BUFD is about completely spec'n and documenting the anticipated
future inner workings of all the features of the proposed design. OOD is concerned
with arranging what code you have so that it will be easy to change.

Agile process guarantee change, otherwise you'll be rewriting your code during
every iteration. Agile thus requires design.

### Judging Design

Remember when lines of code were a thing? That was a metric that wasn't helpful to
anyone, especially developers.

Now, you can even find Ruby gems that will assess how well your code follows OOD
principles. You can run these tools to gain insight into your app, but even well-
designed apps can have many violations.

*Always take these metrics with a grain of salt* They provide unbiased numbers for
you to infer something about software, but they aren't indicators of quality.

*The ultimate software metric would be cost per feature over the time interval
that matters*.

Technical debt can happen when you are designing and that takes time, which costs
monies. *When the act of design prevents software from being delivered on time,
you have lost.*

Good design that continues to pay off is worth a lot, paying back continually.
Daily compunding interest adds up over time.

The break-even point for design depends on the programmer. 

## A Brief Intro to Object-Oriented Programming

Made up of objects that the messages that pass between them.

### Procedural Languages

Non-OO is procedural. There is a chasm between data and behavior. Data is one thing,
behavior is something completely different. Data gets packaged up into variables and
then passed around to behavior, which can do anything it wants to the data.

Data is like a child that behavior sends off to school every morning; there is no
way of knowing what actually happens while it is out of sight. The influences on data
can be unpredictable and largely untraceable.

### Object-Oriented Languages

Objects have behavior and may contain data, data to which they alone control access.
Objects invoke one another's behavior by sending each other messages.

Think about strings in Ruby. It's an object, not a datatype. it needs to only provide
a way for objects to send messages. If the String object understands the `concat`
message, Ruby doesn't have to contain syntax to concatenate strings, it just has to
provide a way for one object to send `concat` to another.

Class-based OO langies allow you to define a class that provides a blueprint for
the construction of similar objects. It defines **methods** (behavior definitions)
and **attributes** (variable definitions). Methods get invoked in response to
messages. And the same method name can be fined by many different objects; it is
up to Ruby to find and invoke the right method of the correct object for any sent
message.

OO Langies are thus open-ended. No set limit to a small set of built-in types and
prefined operations; You can invent brand new types of your own. Each OO app
gradually becomes a unique programming language that is specifically tailor to your
domain.

Whether this langie ultimately brings you pleasure or pain is a matter of design
and the concern of this book.

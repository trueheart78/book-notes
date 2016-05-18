[&lt;&lt; Back to the README](README.md)

# Chapter 2. Functions, Scope, and Context

The hear and soul of CoffeeScript can be summed up in two characters: `->`.
That's all it takes to define a new function, and it can be very powerful.

CoffeeScript's most useful features are property arguments, default arguments,
and splats.

## Functions 101

```coffee
console.log 'Hello, functions!'
```

should output `Hello, functions!`. Now, let's CoffeeScript it up.

```coffee
console.log (-> 'Hello, IIFE!')()
```

should output `Hello, IIFE!`.

Why?

1. `->` defines a function.
2. CoffeeScript has implicit returns, like Ruby.
3. Putting `()` after the function expression causes it to be called, and the
   result of that call is passed to `console.log`.

Wtf is `IIFE`? It stands for the pattern of defining a function and calling it
right away. It is pronounced "iffy", an Immediatedly Invoked Function Expression.

Functions are first-class objects in JS, as they can be passed around and even
assigned to variables:

```coffee
returnGreeting = -> 'Hello, function variable!'
console.log returnGreeting()
```

outputs `Hello, function variable!`

**CoffeeScript does not support named functions, a JS feature that allows
functions to be called before they're defined.**

### Taking Arguments

Pretty easy:

```coffee
greet = (subject) -> "Hello, #{subject}!"
console.log greet 'argument'
```

Outputs: `Hello, argument!`.

This is different, definitely. Also notice the Ruby-esque string interpolation.

### Multiline Functions

CoffeeScript is a **whitespace-sensitive language**. To define a multiline function,
the function body must be indented.

```coffee
getCurrentDate = ->
  now = new Date
  "#{now.getMonth()}/#{now.getDay()}, #{now.getFullYear()}"
```

CS doesn't care what you indent with, as long as it is consistent. CoffeeLint
can help with that, if needed.

Also, the whitespace rule applies to all other language constructs in CS:

```coffee
pluralize = (count, word, suffix = 's') ->
  if count is 1
    word
  else
    word + suffix
```

One of CS's core tenets is, "Everything is an expression." An expression is a
statement that has a value. In JS, conditionals have no value. In CS, they do.

You can write them on one line.

```coffee
  if strikes >= 3 then out()
```

### The Existenstial Operator and Default Arguments

To check that a variable has a value (not `null` nor `undefined`), we can use the
**existential operator**, expressed as a question mark:

```coffee
if i?
  think()
```

This can be used to assign values. If the first has a value, the second if it does
not:

```coffee
myChoice = firstChoice ? secondChoice
```

Also, you can use it to assign, if the variable doesn't already have a value:

```coffee
dinner ?= 'macAndCheese'
```

You can use default arguments, too:

```coffee
buyAnything = (retailer = 'amazon') ->
```

This means basically `retailer ?= 'amazon'`.

### Splatted Arguments

A long list of arguments, but you just want it as an array? Instead of the
stock `arguments` object that JS has, CS has you covered:

```coffee
showOff = (allArguments...) ->
  console.log allArguments
```

The trailing ellipsis means that `allArguments` "soaks" all of the args from that
spot forward:

```coffee
showOff()
showOff('once', 'twice', 'thrice')
```

Outputs:

```sh
[]
['once', 'twice', 'thrice']
```

You can use splats on the calling side of a function as well. Splatted function
calls transform an array into a list of args.

```coffee
numbers = [5.4, 9.4, 1.8, 2.2]
console.log Math.min(numbers...)
```

Outputs `1.8`.

Splats are also useful for constructing and extracting values from arrays.

## Variable Scope

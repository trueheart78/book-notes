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

Scoping:

1. Every function creates its own scope. (standard)
2. Functions are the *only* constructs that create scope. (okay)
3. Each variable lives in the outermost scope in which a value is (potentially)
   assigned to it.

The last one allows CS to do away with `var`. Take care not to use the same var
name in two different, nested scopes.

### All Functions Are Closures

This means that they have access to all variables in all surrounding scopes -
regardless of where they are called from:

```coffee
X = 5
sumXY = -> X + Y
Y = 7
console.log sumXY()
```

Outputs `12`

Both `X` and `Y` are declared in the scope surrounding `sumXY`, so it has access
to both vars. It doesn't matter that `Y` isn't mentioned until after the
declaration. Variable scope is defined at compile time.

```coffee
showCount = (->
  count = 0
  ->
    count += 1
    console.log count
)()
showCount()
showCount()
showCount()
```

Outputs

```sh
1
2
3
```

Why?

1. The inner function is defined to increment `count` and display value.
2. The IIFE declares `count`, set to `0`, and returns the inner function.
3. Because the inner function is returned by the IIFE, that's what `showCount`
   becomes.

JS and CS don't featre "private" or "static" variables.

### Capturing Variables

A classic `for` loop will cause trouble:

```coffee
for i in [1, 2, 3]
  setTimeout (-> console.log i), 0
```

Outputs:

```sh
3
3
3
```

This has to with compile time values. Try the following instead:

```coffee
for i in [1, 2, 3]
  do (i) ->
    setTimeout (-> console.log i), 0
```

and get

```sh
1
2
3
```

`do` is a CS keyword designed for this: it calls the given function, passing in
the vars whose names match those of the args.

You do create 6 functions in the above code, which could prove problematic.

## Execution Context

JS has two special objects created everytime a function is called: `this` and
`arguments`, the latter we've already coverd.

`this` allowed functions to be used as *methods*, meaning they can be attached
to an object and know which object they are attached to.

```coffee
fry = {}
fry.name = 'Philip J. Fry'
fry.sayName = -> console.log(this.name)
fry.sayName()
```

Outputs `Philip J. Fry`.

Because `this` is so important, CS allows the `@` symbol to be ysed as a synonym
for it. `@x` is a stand-in for `this.x`, and is preferred (at least by the
  author).

### Controlling Context

When you call a function by writing `obj.func()`, `func` is called in the context
of `obj`. If you call a function directly by writing `func()`, then `func` is
called in the context of the *root object*. In the browser, that is `window`. In
Node, it's called `global`.

If you want to control the context of a function call, you have access to a few
different methods: `call` and `apply`. Both take the context as their first arg.
`call` passes all subsequent arguments along to the function:

```coffee
tribble = {count: 2}
multiple = (multiplier) -> @count *= multiplier
multiply.call(tribble, 16)
console.log tribble.count
```

Outputs `32`.

Meanwhile, `apply` takes an array as its second arg and expands that into a list
of args for the function. `apply` is how splatted calls are implemented.

These are 2 equal functions:

```coffee
console.log Math.min.apply(Math, numbers)
console.log Math.min(numbers)
```

You can always use splats instead of `apply`, *as long as the context you want
is the same as the object to which the function is attached.*

### Bound Functions

While `this` is super useful, there are times when we want a function we define
to only use the value of `this` in the surrounding function. Like for callbacks.

CS gives us a dedicated syntax for *bound functions*:

```coffee
majorTom = {secondsLeft: 4}
majorTom.countdown = ->
  setTimeout (=>
    console.log @secondsLeft
    @secondsLeft--
    if @secondsLeft > 0
      @countDown()
  ), 1000
majorTom.countDown()
```

Outputs:

```sh
4
3
2
1
```

Notice the `=>` instead of the `->` when defining the timeout function. It makes
a copy of the `this` context for use internally in the function, making `=>` a
very easy way to access it.

## Mini-Project: Checkbook Balancer

Write a simple, old-school computer program to track where we're keeping our
money across three accounts: checking, savings, and our mattress.

```coffee
createAccount = (name) ->
  {
    name: name
    balance: 0

    description: ->
      "#{name}: #{dollarsToString(@balance)}"

    deposit: (amount) ->
      @balance += amount
      @

    withdraw: (amount) ->
      @balance -= amount
      @
   }
```

Returning `@` from each method enables us to perform method chaining.

```coffee
checking = createAccount('Checking')
savings  = createAccount('Savings')
mattress = createAccount('Mattress')
```

The core of the app is now done. Time for some UI.

The book recommends using an npm library called Inquirer.js.

```sh
npm install --save inquirer
```

This also adds it to our project's `package.json`. Keep it in sync with your
`node_modules`, as well.

And also, the Numeral.js formatting library for currency.

```sh
npm install --save numeral
```

```coffee
numeral = require ('numeral')

dollarsToString = (dollars) ->
  numeral(dollars).format('$0,0.00')

inputToNumber = (input) ->
  parseFloat input.replace(/[$,]/g, ''), 10
```

**Note:** There is more in the book that I did not cover, but it seemed pretty
straight-forward.

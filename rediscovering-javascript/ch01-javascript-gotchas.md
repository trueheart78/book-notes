[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Variables and Constants 🔜][upcoming-chapter]

# Chapter 1. JavaScript Gotchas

## Be Careful Where You Break Lines

Lot's of langs don't care about semicolons and they can be option; not in JS.

**JS has the philosophy that it's more fun to take revenge than to complain**

Putting a ; in doesn't always work, because you have to be aware of JS's automatic semicoclon
insertion (ASI) rules.

A valid program ends with a ;. If it doesn't, JS puts one there.

```
let first
second = 1;
```

The bad part of this code is that the _token_ `second` is not expected after `first`, even though a
line break separates the two. So JS inserts a `;` before the variable `second`, causing `first` to
be set to `undefined` and the variable `second` becoming _global_.

If a candidate token is `break`, `continue`, `return`, `throw` or `yield` and a line break appears
between the candidate token and the next, then JS inserts a `;` after the candidate token.

```
const compute = function(number) {
  // Good
  if(number > 5) {
    return number
      + 2;
  }

  // Bad
  if(number > 2) {
    return
      number * 2;
  }
};
```

Since the second `return` is followed by a newline, JS puts in a `;` right after, thus returning
nothing, aka `undefined`.

In the first `return` it is legal for `+` to follow `number` so no `;` was inserted.

If a line is short, end it with a clearly visible semicolon. If a line is long, break it into
multiple lines in a way that ASI won't get in the way.

## Use === Instead of ==

Comparing using `==` is the type-coercion non-strict equality operator. 

```
const a = '1';
const b = 1;
const c = '1.0';

console.log(a == b); // true
console.log(b == c); // true
console.log(a == c); // false?
```

You can see that the `==` operator does not honor the transitive property of equality, due to type
coercion. The output tells the story.

If the types are `string`, `number`, or `boolean`, then a direct equality check is performed. So
when we compared differing types, they were coerced. When we compared two strings, a lexical
comparison was used.

Sometimes, `==` is the right choice. `variable == null` will be `true` if the variable is `null` or
`undefined`, instead of a `===` check like `variable === null || variable === undefined`.

Let's rework the above to use `===`:

```
const a = '1';
const b = 1;
const c = '1.0';

console.log(a === b); // false
console.log(b === c); // false
console.log(a === c); // false
```

Just like the way we should use `===` instead of `==`, use `!==` instead of `!=` to check
inequality.

## Declare Before Use

JS seems highly flexible, but it makes some design decisions if we leave out the good stuff. Like
globalizing variables that should be scoped to functions :(

```
const oops = function() {
  haha = 2;
  console.log(haha)
};

oops();
console.log(haha);
```

So above you get a nice global `haha` variable. This can be very painful. Loops can coincide.

```
const outer = function() {
  for(i = 1; i <= 3; i++) {
    inner();
  }
};

const inner = function() {
  for(i = 1; i <= 5; i++) {
    console.log(i);
}

outer(); // output: 1 2 3 4 5
```

Since neither `i` is used before being declared, it's marked as global. So `inner()` takes all the
iterations, and `outer()` is completed. Now just imagine that somehow `i` got set above `5`.
Infinite loop ensues.

Here's a fixed version:

```
const outer = function() {
  for(let i = 1; i <= 3; i++) {
    inner();
  }
};

const inner = function() {
  for(let i = 1; i <= 5; i++) {
    console.log(i);
}

outer(); // output: 1 2 3 4 5 1 2 3 4 5 1 2 3 4 5
```

## Stay One Step Ahead

These issues have been around forever, and now there is a way to help alleviate the burning
sensation when they happen.

### Apply the `use strict` Directive

Placing `'use strict';` at the beginning of a source file or within a fn turns on the strict mode of
execution. It adheres to the scope (file or fn), and does not allow unset variables, as well as
changes to read-only properties, deletion of properties, and the use of some keywords that are
reserved for the future, to mention a few.

When you are refactoring large codebases, the fn-level scope is a good place to start.

Since it appears as a `string`, newer JS engines can recognize it while older ones can ignore it.

### Lint the Code

Setup a linter like ESLint

```
npm install -g eslint
```

Then run

```
eslint --init
```

You can then run it against files or entire project directories:

```
eslint .
```

Using ESLint from within an IDE and during a continuous integration build process, we can
proactively detect and avoid potential mishaps.
[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Variables and Constants 🔜][upcoming-chapter]

[readme]: README.md
[upcoming-chapter]: ch02-variables-and-constants.md

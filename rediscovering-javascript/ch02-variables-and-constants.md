[🔙 JavaScript Gotchas][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Working with Function Arguments 🔜][upcoming-chapter]

# Chapter 2. Variables and Constants

## Out With `var`

Pre-ES6, `var` was the variable defining way. If we forget to define a var explicitly before
assigning to it, we'll end up with a global. the `'use strict';` directive saves us from that error.
You should always define a variable before using it. Just don't use `var`.

`var` has two flaws:
1. It doesn't prevent a var from being redefined in a scope.
2. It does not have block scope.

In short, `var` is a mess; don't use it.

## In With `let`

`let` is the sensible replacement for var. 

### Block Scoping

```
for(let i = 0; i < 3; i++) {
  let message = 'spill ' + i;
}
```

## `const`

The `const` keyword is used to define, well, a constant.

```
'use strict';
let price = 120.25;
const tax = 0.825;

price = 110.25 // No error
tax = 0.850 // Error
```

### Reach of `const`

Only primitives like `number` and references to objects are protected from change. The actual object
that the reference refers to does not receive any protection from the use of `const`. So while an
object might be made a `const`, it doesn't mean that it's methods are safe from change in value.

### Making Objects `const`

```
'use strict';

const sam = Object.freeze({ first: 'Sam', age: 2 });

sam.age = 3; // Error
```

Keep in mind that `freeze()` is shallow.


## Safer Code with `let` and `const`

## Prefer `const` over `let`

Rules:
1. Don't use `var`. Just don't.
2. Use `const` wherever possible.
3. Use `let` where mutability is actually needed.

Benefits to choosing `const` over `let` first:
- Code is less error-prone
- Code is easier to reason about
- Prevents accidental or unintentional change to variables
- Safe to use in functional style code or with arrow functions.

[🔙 JavaScript Gotchas][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Working with Function Arguments 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch01-javascript-gotchas.md
[upcoming-chapter]: ch03-working-with-function-arguments.md

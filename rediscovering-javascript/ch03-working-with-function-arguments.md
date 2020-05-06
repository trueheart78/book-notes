[🔙 Variables and Constants][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Iterators and Symbols 🔜][upcoming-chapter]

# Chapter 3. Working with Function Arguments

## Using the Rest Parameter

```
const max = function(...values) {
  console.log(values instanceof Array) // True
};
```

This works instead of using the `arguments` keyword, and gives you a real `Array` instead of a
wannabe.

Rules for the rest parameter:
- The rest parameter has to be the last formal parameter.
- There can be at most one rest param in a fns param list.
- The rest param contains only values that have not been given an explicit name.

## The Spread Operator

```
const greet = function(...names) {
  console.log('hello ' + names.join(', '));
};

greet('Jack', 'Jill'); // hello Jack, Jill

const tj = ['Tom', 'Jerry'];
greet(tj[0], tj[1]); // hello Tom, Jerry

greet(...tj) // hello Tom, Jerry
```

The spread operator may be used with any iterable object and it expands (or spreads) the contained
values into discrete values.

No more use for the `apply()` fn that is in JS now that the spread operator exists.
[🔙 Variables and Constants][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Iterators and Symbols 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch02-variables-and-constants.md
[upcoming-chapter]: ch04-iterators-and-symbols.md

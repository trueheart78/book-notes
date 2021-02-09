[🔙 Working with Function Arguments][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Arrow Functions and Functional Style 🔜][upcoming-chapter]

# Chapter 4. Iterators and Symbols

## The Convenience of Enhanced `for`

`for` loops: strong, powerfule, core.

### Simple Iteration Over Elements

```
const names = ['sara', 'jake', bill', bob'];

for(const name of names) {
  console.log(name);
}
```

Produces the basic `for` loop but is easier to read. Concise and less error prone, too.

We can use `for...of` on any object that supports iteration, namely, the `[Symbol.iterator]()`
method.

### Getting the Index

The `entries()` fn of `Array` returns another iterator, which has the key plus the value.

```
const names = ['sara', 'jake', 'nill', paul'];

for(const [i, name] of names.entries()) {
  console.log(i + '--' + name);
}
```

Nice and easy way to ignore the index until we need it.

## Symbol -- A New Primitive Type

JS had five primitive types:
1. `number`
2. `string`
3. `boolean`
4. `null`
5. `undefined`

Now, enter `Symbol`. Limited specialized use for three purposes:
- To define properties for objects in a way they don't appear during normal iteration.
- To easily define a global registry or dictionary of objects.
- To define some special well-known methods in objects, which fills the void of interfaces.

Interfaces in langs like Java and C# are useful for design-by-contract and serve asa
specification or a listing of abstract fns. When a fn expects an interfaces it is guaranteed, in
these langs, that the object will conform to the specs. JS doesn't have this, but `Symbol` helps
fill the gap.

### Hidden Properties

```
const age = Symbol('ageValue');
const email = 'emailValue';

const sam = {
  first: 'Sam',
  [email]: 'sam@example.com',
  [age]: 2
};
```

`age` is defined as a `Symbol` using the `Symbol()` fn. Iterating over these properties,
`ageValue` will not appear. You can use `Object.getOwnPropertySymbols(sam)` and attain the list of
symbols.

[🔙 Working with Function Arguments][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Arrow Functions and Functional Style 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch03-working-with-function-arguments.md
[upcoming-chapter]: ch05-arrow-functions-and-functional-style.md

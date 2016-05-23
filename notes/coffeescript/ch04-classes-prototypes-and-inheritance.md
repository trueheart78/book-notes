[&lt;&lt; Back to the README](README.md)

# Chapter 4. Classes, Prototypes, and Inheritance

**types** of objects can be defined/described as *prototypes* in JS. You can
share methods and data across many objects. This is different than C++ or Ruby
or even Java.

CS has some help for merging these ideas so our brain doesn't explode: `class`
and `extends`.

## The Power of Prototypes

A prototype is an object whose properties are shared by all objects that have
that prototype. You can usually access them for an object using the `prototype`
property. Usually.

You must, however, instantiate them.

```coffee
Boy = ->
Boy::sing = ->
  console.log "This is the song that never ends..."
sue = new Boy()
sue.sing()
```

## Making Objects with Constructors

When we write `new <constructor>`, a new object is created, it is given the
prototype from the constructor, and the constructor is executed in the new
object's context.

```coffee
Gift = (@name) ->
  Gift.count++
  @day = Gift.count
  @announce()

Gift.count = 0
Gift::announce = ->
  console.log "On day #{@day} I received #{@name}"

gift1 = new Gift('a new SNES')
gift2 = new Gift('a new PlayStation')
```

The syntax `(@name) ->` is shorthand for `(name) -> @name = name`

Everytime the above `Gift` constructor runs, it does four things:

1. assigns the given name to @name
2. increments the `count` property on the `Gift` constructor
3. copies the `count` property value to `@day`
4. runs the `@announce` function inherited from the prototype

These all run in the context of the object. Prototypes are the reason that the
`this` keyword is essential to JS. Prototypes allow a single function to be
shared across many objects.

Regarding parantheses, constructors have some quirks:

1. invoking a constructor without args, you can omit the parens
2. parens do matter when invoking a constructor attached to an object, like
   `new x.Y()` and `new X().y`
3. omitting parens places them at the end of the statement. `new x.Y` is the
   same as `new x.Y()`

These rules come from JS, btw.

### Prototype Precedence

When an object inherits properties from a prototype, changes to the prototype
will change the inherited properties as well:

```coffee
Raven = ->
Raven::quoth = -> console.log 'Nevermore'
raven1 = new Raven
raven1.quoth()     # Nevermore

Raven::quoth = -> console.log 'Ned sent me'
raven1.quoth()     # Ned sent me
```

Properties attached directly to objects take precendence over prototype
properties. We can remove ambiquity in the previous example like this:

```coffee
raven2 = new Raven
raven2.quoth = -> console.log 'You do not own me'
raven1.quoth()     # Ned sent me
raven2.quoth()     # You do not own me
```

**Think of this as overriding an inherited/extended method/property**

You can check if a property is attached to an object directly, or inherited,
with the `hasOwnProperty` function:

```coffee
console.log raven1.hasOwnProperty('quoth')  # false
console.log raven2.hasOwnProperty('quoth')  # true
```

Also, `obj.a = obj.a` can sometimes make changes to the object:

```coffee
raven3 = new Raven
console.log raven3.hasOwnProperty('quoth')  # false
raven3.quoth = raven3.quoth
console.log raven3.hasOwnProperty('quoth')  # true
```

If this seems messy, CS's `class` keyword is our rescuer.

[&lt;&lt; Back to the README](README.md)

# Chapter 3. Collections, Iteration, and Destructuring

All code is, at its core, about data: reading, transforming, and emitting.

JS makes working with arrays and hash maps quite easy, and CS goes one step
further.

## Objects as Hash Maps

Storing arbitrary named values is important, regardless if you term them
hash maps, dictionaries, or associative arrays. It's a key + value, where
you use the key to fetch the value.

In JS, every object is a hash map. Almost everything is an object, too, except
for *primitives* (Booleans, numbers, and strings), and some special constants,
like `undefined` and `NaN`. CS has many special features aimed at making it
easier to work with them.

### Creating Objects

Use **JSON-style** syntax:

```coffee
obj = {key: 'value'}
```

In CS, the braces are optional:

```coffee
obj = key: 'value'
```

You can also omit commas that usually separate key-value pairs. Very YAML-like.

```coffee
credentials =
  username: 'Yorick'
  password: 'hamilton'
```

Note that keys are kept at the same level of indentation. Deeper = nested.

```coffee
sprite =
  image: 'blip.gif'
  position:
    x: 50
    y: 40
```

Omitting curly braces is nice, but it becomes super useful when you want to
define an object where a key is the same name of a variable. Here's the gist:

```coffee
position = if offScreen then 'absolute' else 'relative'
$el.css {position} #equivalent to {position: position}
```

## Using Objects

It's nice to be able to use dot notation (`obj.x`) and bracket notation
(`obj['x']`). Generally, use the first if you know a key at compile time, and
the latter if you need to determine it at runtime. Or, when you are dealing
with a literal key:

```coffee
symbols.+ = 'plus' # illegal syntax
symbols['+'] = 'plus' # valid
```

CS does, however, automatically replace dot notation with bracket notation
when you use a reserved keyword, because some JS runtimes can't deal.

`symbols.if` compiles to `symbols["if"]`.

You can combine reading and writing from object with the existential operator.

```coffee
sprite?.coordinates # read sprit.coordinates if sprite exists
sprite?.opacity = 1 # set the opacity if sprite exists
```

You can chain the operator when uncertain of nested objects:

```coffee
console?.log?('Better safe than sorry')
```

You can also read multiple values from an object int vars with a single
expression, termed **destructuring**:

```coffee
{x, y} = coordinates
```

If the inverse would define an object named `coordinates` and set the `x` and
`y` values, this simple describes a pattern for reading object values into
vars.

You will generally see this in arg lists, to pull data from a single object
argument:

```coffee
fire = ({x, y}) =>
  if x is 5 and y is 7
    console.log "direct hit"
```

Be warned that destructuring does not check for existence of the object.

## Arrays



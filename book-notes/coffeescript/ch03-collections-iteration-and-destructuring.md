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

Arrays can be defined using a JSON-style syntax:

```coffee
mcFlys = ['George', 'Lorraine', 'Marty']
```

All arrays in JS are dynamic, with no set length.

```coffee
mcFlys = []
mcFlys[] = 'George'
mcFlys[] = 'Lorraine'
mcFlys[] = 'Marty'
```

Arrays are objects, hence the brackets. Indices are just object keys, whcih are
all strings, so `arr[1]`, `arr['1']`, and `arr[{toString: -> '1'}]` are the
same. The nice thing about using numbers, though, is the `length` property
becomes useful.

### Ranges

CS adds a Ruby-esque syntax for defining arrays of consecutive integers:

```coffee
[1..5] #=> [1, 2, 3, 4, 5]
```

That is an **inclusive range**. However, when we don't want the last item, use
the **exclusive range**:

```coffee
[1...5] #=> [1, 2, 3, 4]
```

Ranges can also go backward.

```coffee
[5..1] #=> [5, 4, 3, 2, 1]
```

And yes, the exclusive range as well.

```coffee
[5...1] #=> [5, 4, 3, 2]
```

Not used too often by itself, but quite handy for `for` loops.

### Slicing and Splicing

When you want to tear a chunk of data out of a JS array, you turn to mr `slice`

```coffee
['a', 'b', 'c', 'd'].slice 0, 3 #=> ['a', 'b', 'c']
```

Slice takes two indices and copies up until the second index, lice an
exclusive range.

```coffee
['a', 'b', 'c', 'd'][0...3] #=> ['a', 'b', 'c']
```

```coffee
['a', 'b', 'c', 'd'][0..3] #=> ['a', 'b', 'c', 'd']
```

The rules here are a lil different, due to `slice`. If the first index comes
after the second, the result is an empty array, not a reversal:

```coffee
['a', 'b', 'c', 'd'][3...0] #=> []
```

Also, negative indices count backward from the end of the array. When calling
`arr[-1]`, it looks for an index named `-1`. `arr[0...-1]` means "give me a
slice from the start of the array up to, but not including, its last element."
It basically means mean the same thing as `arr.length - 1`.

```coffee
['a', 'b', 'c', 'd']p0...-1] #=> ['a', 'b', 'c']
```

If you omit the second index, the slice goes all the way to the end, regardless
of dot count.

```coffee
['this', 'that', 'the other'][1..]  #=> ['that', 'the other']
['this', 'that', 'the other'][1...] #=> ['that', 'the other']
```

CS also provides a shorthand for `splice`, the value-inserting cousin of
`slice`. It looks like you're making an assignment to the slice:

```coffee
arr = ['a', 'c']
arr[1...2] = ['b']
arr #=> ['a', 'b']
```

The range defines the part of the array to be replaced. If the range is empty,
like `1...1`, there is an insertion without a replacement:

```coffee
arr = ['a', 'c']
arr[1...1] = ['b']
arr #=> ['a', 'b', 'c']
arr[1..1] = ['2'] #=> ['a', 2, 'c']
```

While negative indices work for slicing, they fail when splicing, except when
omitting the last index.

Also, string have a `slice` method, which is basically a substring.

```coffee
'The year is 20XX'[-4..] #=> 20XX
```

There is no native `splice` for strings, and since JS strings are immutable,
you cannot add one.

## Iterating over Collection

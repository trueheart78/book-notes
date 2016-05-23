[&lt;&lt; Back to the README](README.md)

# Chapter 1. Getting Started

With the right tools, using CoffeeScript should be just as easy as using Javascript.

## Installing CoffeeScript

The CoffeeScript compile is written in CoffeeScript. So how do you run it if you
don't have it installed?

The answer: Node.js.

### Installing Node.js

If you don't have it installed, you can use a package manager or download it from
[https://nodejs.org](https://nodejs.org).

You can use nvm if you would like to have multiple versions of Node installed at
any one time.

```sh
node -v
```

You should now have access to two new commands: `node` and `npm`. npm is Node's
package manager.

Make sure you have npm setup:

```sh
npm -v
```

If you have Node but not npm, try a different installation method for Node.

[Installing Node.js via package manager](https://nodejs.org/en/download/package-manager/)

### Installing the coffee-script Package

```sh
npm install -g coffee-script@1.8.0
```

This should install version 1.8.0 of the `coffee-script` package. The `-g` is a
global option that tells npm we want it available to the whole system, not just
the local dir.

You now have access to `coffee` and `cake`, with symlinks setup.

`cake` is CoffeeScript's version of `make` or `rake`.

```sh
coffee -v
```

## Running and Compiling CoffeeScript

CoffeeScript has a REPL ("read-eval-print loop") where you can run commands
interactively, like `irb`.

```sh
coffee
coffee> audience = 'world'
'world'
coffee> "Hello, #{audience}!"
'Hello, world!'
```

To exit, `ctrl-d`.

If you want to run a CoffeeScript file that ends in `.coffee`, you can just:

```sh
coffee script.coffee
```

If you want to compile it to JavaScript, you can pass the `-c` flag. Then you
will have a `.js` version, that can be run with `node script.js`.

While we like the `coffee` command, later on, Grunt will be used to do the
heavy lifting.

## Using Source Map

Compiled JS can be delivered to the browser just as it would be otherwise, using
source maps: compiled, concatenated, and minimied.

```javascript
//# sourceMappingURL=myScript.js.map
```
 
 A developer can view this, while a normal use will never notice it.

 Source maps means that you can actually debug CoffeeScript in the browser now.

 Grunt will later generate source maps alongside our compiled JS and ensure the
 files end up where they need to be.

 If you run the `coffee` command with the `-m` flag, it will also generate a
 map file.

 Source maps should be supported in Rails soon (if not already).

## Editing CoffeeScript

Use your favorite editor. Also, see if there is a way to one-button run the file
from your editor.


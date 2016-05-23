[&lt;&lt; Back to the README](README.md)

# Chapter 5. Web Applications with jQuery and Backbone.js

[Coffee Tasks repo](https://github.com/trueheart78/cs-coffee-tasks)

jQuery was launched in 2006, and became a wonderful abstraction of many of the
different problems each browser might have, and introduced an ingenious CSS-like
element selection syntax.

Web apps have grown more and more complex, as well, and many MVC frameworks have
cropped up to provide some organization structure. Backbone.js is one of the
most popular, and it was written by the CS creator. It's a relatively minimal
framework, making it suitable to a wide range of apps. Also, BB uses classes
that are intercompatible with CS classes, so for CS, BB makes good sense.

Try the docs for these items if you need more than this book covers.

## Building the Project with Grunt

We have a problem we need to solve before we dive in our project's code:
browsers don't understand CS. Or Eco, the templating lang. The only understand
JS, which means transforming our source files in JS.

**We will use Grunt, a Node.js-based task runner.**

Grunt and Gulp are similar, but Grunt was chosen for the simple reason that it
is more widely used (as of time of writing).

Setup the project directory:

```sh
mkdir coffee-tasks
cd coffee-tasks
npm init
```

Follow the npm prompts and you will end up with the initial `package.json`.

```sh
npm install -g grunt-cli
npm install --save-dev grunt@0.4.5
npm install --save-dev grunt-eco
npm install --save-dev grunt-contrib-coffee
npm install --save-dev grunt-contrib-watch
```

You can see that Grunt was installed globally, and then we had to set it up for
development usage. Even when you install Grunt globally, it is just a thin
wrapper called `grunt-cli` that loads the `grunt` project from the local 
project. So every project can have its own Grunt (and this one actually needs
an older version, so that's handy).

Gruntfile:

```coffee
module.exports = (grunt) ->
  grunt.loadNpmTasks('grunt-eco')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-coffee')

  grunt.initConfig
    watch:
      coffee:
        files: 'src/*.coffee'
        tasks: ['coffee:compile']
      eco:
        files: 'templates/*.eco'
        tasks: ['eco:compile']

    coffee:
      compile:
        expand: true
        flatten: true
        options:
          sourceMap: true
        cwd: 'src/'
        src: ['*.coffee']
        dest: 'compiled/'
        ext: '.js'

    eco:
      compile:
        src: 'templates/*.eco'
        dest: 'compiled/templates.js'

  grunt.registerTask('build', ['coffee', 'eco'])
  grunt.registerTask('default', ['build', 'watch'])
```
This file does three things:

1. Compiles our CS files from the `src` dir into the `compiled` dir.
   We'll also get a `js.map` file thanks to the `sourceMap: true` option.
2. Compiles our Eco files from the `templates` dir into the `compiled` dir.
3. Watches the CS and Eco files and recompiles them whenever they change.
   (It's a lot like the Guard gem in Ruby)

This is great for local development, so it has been made the `default` task,
which means just running `grunt` will take care of things.

```sh
 grunt
```

Grunt is a very flexible tool. It could also concat our JS, run tests, and
even deploy files to staging or production servers. You should also consider
[Automate with Grunt](https://pragprog.com/book/bhgrunt/automate-with-grunt)
from The Pragmatic Bookshelf.

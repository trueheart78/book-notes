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

*Gruntfile.coffee*

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

## Managing Front-End Dependencies with Bower

Automating JS library installs is made easier thanks to package managers
inspired by npm; most motably Bower.

Install Bower globally with npm:

```sh
npm install -g bower
```

Once installed, Bower can prepare any project for front-end dependency mgmt
with its own `init`:

```sh
bower init
```

You'll end up with a `bower.json` file. Now, install these:

```sh
bower install --save jquery
bower install --save backbone
```

Simple enough! Now, Bower (unlike AMD) doesn't tell us *how* to load the
dependencies it installs. We just use classic `script` tags, and away we go!

*index.html*

```html
<!<DOCTYPE html>
<html>
<head>
  <title>CoffeeTasks</title>
  <!-- Libraries -->
  <script src="bower_components/jquery/dist/jquery.js"></script>
  <script src="bower_components/underscore/underscore.js"></script>
  <script src="bower_components/backbone/backbone.js"></script>

  <!-- Default data -->
  <script src="compiled/data.js"></script>

  <!-- Templates -->
  <script src="compiled/templates.js"></script>

  <!-- Backbone models/views -->
  <script src="compiled/card.js"></script>
  <script src="compiled/column.js"></script>
  <script src="compiled/board.js"></script>

  <!-- Application core -->
  <script src="compiled/application.js"></script>

  <!-- Stylesheets -->
  <link rel="stylesheet" href="css/normalize.css">
  <link rel="stylesheet" href="css/style.css">
</head>
<body>
  <!-- All content is rendered client-side -->
</body>
</html>
```

Now that you have the `index.html` file, let's get on to the nuts and bolts:
templates, models, and views.

## Building the Page with Templates

Rendering HTML is fundamental to a web app. Then you have client- vs server-
side rendering, a whole 'nother discussion.

We could dive deeper into these opinions, but you came here to learn CS. So we
will focus on the templating language to called Eco to generate HTML using CS.
Eco allows you to write templates that look like HTML with CS snippets thrown
in for conditionals and loops (think ERB). It can be rendered on the server,
but we'll stick to client-side so that we don't have to write a Node server
just yet (that's the next chapter).

Templates we'll need? Well, we'll have a 1:1 correspondence between templates
and BB views, as well as between BB views and models. Here's the rundown:

+ A board, with a name and a number of columns to group task cards
+ A column, with a name and containing any number of task cards
+ A task card, with a description and a due date.

Let us mark them up.

*templates/board.eco*

```eco
<input name='board-name' value='<%= @name %>'>
<div class='column-container'>
  <% for column in @columns : %>
    <div class='column' data-column-id='<%= column.id %>'></div>
  <% end %>
  <button name='add-column'>Add Column</button>
</div>
```

*templates/column.eco*

```eco
<input name='column-name' value='<%= @name %>'>
<div class='card-container'>
  <% for card in @cards : %>
    <div class='card' data-card-id='<%= card.id %>'></div>
  <% end %>
  <button name='add-card'>Add Card</button>
</div>
```

*templates/card.eco*

```eco
<textarea name='card-description' placeholder='Description'
  rows='3'><%= @description %></textarea>
<label class='due-date-label'><span>Due by:</span><input type='date'
  name='due-date' value='<%= @dueDate %>'></label>
```



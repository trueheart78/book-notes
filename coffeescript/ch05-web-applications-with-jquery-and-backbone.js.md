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

Now, these templates aren't crazy, by any means. They are very ERB-like.

However, do notice the `date` input type (a fairly cutting-edge browser feature)
that might not be available in a production app (due to the user's browser),
but we're developers, so we can likely use it without issue.

Using BB we'll now bring this markup monster to life. *Muahahahahhahahah!*

## Structuring Data for Persistence

We're going to persist the data as JSON locally, so we'll look at that before
we look at how to represent the data in BB.

This will be a relational schema.

```json
{
  "boards": [
    {
      "id": 1,
      "name": "Pet Tasks",
      "columnIds": [1]
    }
  ],
  "columns": [
    {
      "id": 1,
      "name": "Dog Tasks",
      "cardIds": [1]
    }
  ],
  "cards": [
    {
      "id": 1,
      "description": "Walk the dog",
      "dueDate": "2016-06-06"
    }
  ]
}
```

We could use a more nested, non-relational schema, but card data could be
nested inside of board data, and since columns are never shared across boards,
a scheme like that may work for this small project. However, it would be quite
brittle if we decided to add features.

Now onto BB entity classes.

## Representing Data in Backbone Models and Collections

A **model**, in the BB sense, is an entity that serves as a key-value store
where changes can be observed via event listeners. Also, BB models inherit
methods for syncing their data with a remote server. Simple, but so effective
that models are the heart of BB. **Being able to "listen" for changes to a set
if data is incredibly powerful.** They can tell us to re-render a view, display
a message, or even fetch add'n data. A model layer was not existent in most
pre-BB JS.

BB also defines **collections**, ordered sets of models that can also be
observed via even listeners. When data is loaded from the server (or 
`localStorage`), we're going to load each of the three arrays into a
corresponding collection: one for boards, and columns, and cards.

*src/card.coffee*

```coffee
class window.Card extends Backbone.Model

class window.CardCollection extends Backbone.Collection
  model: Card

cardData = JSON.parse(localStorage.cards)
window.allCards = new CardCollection(cardData, {parse: true})
```

Starts out simple, and doesn't really do much that might seem magical, now that
you know as much as you do. And keep in mind, we're using `localStorage`
instead of a server (for now). To persist data, we'll override `Backbone.sync`,
which provides the persistence functionality underlying every model and
collection's `save` and `fetch` methods.

That's why we have the data being pulled in on line 6 above.

Now, onto the `Column` model, which will be a bit more complicated. We're going
to implement `parse` and `toJSON` methods, which BB uses to convert raw JSON
data into the model's attributes and back.

```coffee
class window.Column extends Backbone.Model
  defaults:
    name: 'New Column'

  parse: (data) ->
    attrs = _.omit data, 'cardIds'

    # convert the raw cardIds array into a collection
    attrs.cards = @get('cards') ? new window.CardCollection
    attr.cards.reset(
      for cardId in data.cardIds or []
        window.allCards.get(cardId)
    )

    attrs

  toJSON: ->
    data = _.omit @attributes, 'cards'

    # convert the cards collection into a cardIds array
    data.cardIds = @get('cards').pluck 'id'

    data
```

So, the `parse` method:

First, we're using Underscore's `_.omit` method to make a shallow copy of the
raw JSON data that exclide `cardIds`. When this copy is returned by `parse`,
it is going to be used as the model's attributes. We're excluding `cardIds`
because we don't want that array to become a part of the model; we want the
cards referenced by that array instead. having both woul cause data duping and
perhaps inconsistencies.

Second, we're creating a `CardCollection` that contains the models returned by
a list comprehension. It goes through `cardIds` and, for each unique ID, gets
the card with that id from `allCards`.

The `toJSON` method simple does the opposite of `parse`, extracting the IDs from
the column's `CardCollection`. The data we return will be persisted to
`localStorage`, potentionally being passed into some new column's `parse`
method.

No work is required for `ColumnCollection`, because when a BB collection is
instantiated with a bunch of raw data, it automatically creates new models and
calls the `parse` method on each one.

*more src/column.coffee*

```coffee
class window.ColumnCollection extends Backbone.Collection
  model: Column

columnData = JSON.parse(localStorage.columns)
window.allColumns = new ColumnCollection(columnData, {parse: true})
```

This setup above allows us to load all the columns from `localStorage`, just
like we did with `allCards`.

*src/board.coffee*

```coffee
class window.Board extends Bacbone.Model
  defaults:
    name: 'New Board'

  parse: (data) ->
    attrs = _.omit data, 'columnIds'

    # convert the raw columnIds array into a collection
    attrs.columns = @get('columns') ? new window.ColumnCollection
    attrs.columns.reset(
      for columnId in data.columnIds or []
        window.allColumns.get(columnId)
    )
    
    attrs

  toJSON: ->
    data = _.omit @attributes, 'columns'

    # convert the columns collection into a columnIds array
    data.columnIds = @get('columns').pluck 'id'

    data

class window.BoardCollection extends Backbone.collection
  model: Board

boardData = JSON.parse(localStorage.boards)
window.allBoards = new BoardCollection(boardData, {parse: true})
```

Now we have the requisite modesl and collections in place. Now they just need
to sync with `localStorage` (which is specific to this app, and not to just BB).

*src/application.coffee*

```coffee
Backbone.sync = (method, model, options) ->
  # we only hjave to handle model syncs (not collection syncs)
  if model instanceof window.Card
    collection = window.allCards
    localStorageKey = 'cards'
  else if model instanceof window.Column
    collection = window.allColumns
    localStorageKey = 'columns'
  else if model instanceof window.Board
    collection = window.allBoards
    localStorageKey = 'boards'

  switch method
    when 'get'  # corresponds to a model.fetch() call
      model.reset collection.get(model.id), {silent: true)
    when 'create'  # model.save on a new model
      model.set 'id', collection.length + 1
      collection.add(model)
      localStorageKey[localStorageKey] = JSON.stringify collection.toJSON()
    when 'update' # model.sve on an old model
      localStorageKey[localStorageKey] = JSON.stringify collection.toJSON()

  # simulate a successful jqXHR
  xhr = options.xhr = jQuery.Deferred().resolve(model.toJSON()).promise()
  options.success(model.toJSON))
  xhr
```

Since this is a `localStorage` app, and not a server-saving one, we do have to
deal with some BB internals (this will disappear in the next chapter).

That's it for the model layer of our app. Now we just need a view layer.

## Presenting Data with Views

A BB view is a DIY kit for turning a model into HTML. BB doesn't perform
rendering or respond to input events or interact with its model unless you
tell it to.

So, first up, a view class for our `Card` model. All it needs to do is render
the model into markup and save changes in the dsecription and due-date fields
to the model.

*adding to src/coffee*

```coffee
class window.CardView extends Backbone.View
  render: ->
    html = JST['templates/card']
      description: @model.get('description')
      dueDate: @model.get('due-date')

    @$el.html html
    @

  events:
    'change [name=card-description]': 'descriptionChangeHandler'
    'change [name=due-date]': 'dueDateChangeHandler'

  descriptionChangeHandler: (e) ->
    @model.save 'description', $(e.currentTarget).val()
    return

  dueDatChangeHandler: (e) ->
    @model.save 'due-date', $(e.currentTarget).val()
    return
```

`render`: when we instantiate the view, we pass in an options hash, and BB 
automatically sets `model` and `$el` as properties when passed. `@model` is a
`Card` instance and `@$el` is a jQuery object that is wrapped around the HTML
element that the view change is in charge of. For `CardView`, that's going to
be a `div` with the `card` class. After putting the HTML from the template in
the DOM, the method returns the view to allow chaining, for example: `cardView
= new CardView(options).render()`.

If this was one-way, we'd be set with `render`, but this isn't, so we aren't.
So the `events` hash is defined, which BB uses to listen for DOM events and send
them to handlers. The hash keys are of the form `"<selector><event type>"`, and
the values are the names of class methods. Using names rather than references to
the methods themselves may seem strange, but BB has to call the methods in the
context of the view object. A call to `view[methodName](e)` does that, while
`method(e)` would only work if `method` were bound to `view`.

The two handlers pull the value from the DOM element and pass it the model's
`save` mathod. It changes the attribute on the model (like `set`), and also
syncs the model to the server (for now, `localStorage`).

Next is `ColumnView`.

*adding to src/column.coffee*

```coffee
class window.BoardView extends Backbone.View
  initialize: (options) ->
    @listenTo @model.get('columns'), 'add remove', =>
      @model.save()
      @render()
    super

  render: ->
    html = JST['templates/board']
      name: @model.get('name')
      columns: @model.get('columns').toJSON()

    @$el.html html

    @model.get('columns').forEach (column) =>
      columnView = new window.ColumnView(model: column)
      columnView.setElement @$("[data-column-id=#{column.get('id')}]")
      columnView.render()
      columnView
    @

  events:
    'change [name=board-name]': 'nameChangeHandler'
    'click [name=add-column]': 'addColumnClickHandler'

  nameChangeHandler: (e) ->
    @model.save 'name', $(e.currentTarget).val()
    return

  addColumnClickHandler: (e) ->
    newColumn = new window.Column({}, {parse: true})
    newColumn.save()
    @model.get('columns').add(newColumn)
    return
```

BB calls `initialize` whenever a class is instantiated. Here, we're using it
to declare an initially empty array of card views and to attach an event
listener to our column's collection of cards, so that we re-render the entire
column every time a card is added or removed. Sure, it's not efficient, but we
can optimize later if it is needed.

The default implementation of `initialize` is a no-op and the return value is
ignored, so ending our implementation with `super` isn't required. But, it does
give us some leeway when refactoring.

The `render` method here has a couple differences to the `CardView`'s. First,
some minor data transformation. We're storing the column's cards as a
`CardCollection` in the `Column` model, and Eco doesn't understand BB
collections, so instead we need to pass in an array containing the card data,
which is what a collection's `toJSON` method gives us. Then, after rendering
the column template we need to create a `CardView` for each card, give it the
DOM element that we just created for it, and tell it to render.

In addition to a name change handler that works just like the input handlers in
`CardView`, the column view has a click handler for the New Card button. When
clicked, it appends a new card with a unique ID to both `allCards` and the
column's collection, which will re-render the column, thanks to the listener
we attached in `initialize`.

Finally, there is `BoardView`.

*add to src/board.coffee*

```coffee
class window.BoardView extends Backbone.View
  initialize: (options) ->
    @listenTo @model.get('columns'), 'add remove', =>
      @model.save()
      @render()
    super

  render: ->
    html = JST['templates/board']
      name: @model.get('name')
      columns: @model.get('columns').toJSON()

    @$el.html html

    @model.get('columns').forEach (column) =>
      columnView = new window.ColumnView(model: column)
      columnView.setElement @$("[data-column-id=#{column.get('id')}]")
      columnView.render()
      columnView
    @

  events:
    'change [name=board-name]': 'nameChangeHandler'
    'click [name=add-column]': 'addColumnClickHandler'

  nameChangeHandler: (e) ->
    @model.save 'name', $(e.currentTarget).val()
    return

  addColumnClickHandler: (e) ->
    newColumn = new window.Column({}, {parse: true})
    newColumn.save()
    @model.get('columns').add(newColumn)
    return
```


## Finishing Touches

Now we only need some initialization logic.

First, some initial data for `localStorage`, if it's empty. So, let's start a
new board, since we can't create one in the app:

```coffee
localStorage.boards ?= JSON.stringify([
  {
    id: 1
    name: 'New Board'
  }
])
localStorage.columns ?= JSON.stringify([])
localStorage.cards ?= JSON.stringify([])
```

If you need to restore this blank slate at any time, use the browser console and
run `localStorage.clear()`.

Finally, the `BoardView` needs initialized.

*add to src/application.coffee*

```coffee
# Wait for the DOM to be ready
$ ->
  # Fetch all boards and display the last (only) one
  board = window.allBoards.last()
  $board = $("<div class='board' data-board-id='#{board.get('id')}'></div>")
  $('body').append $board
  boardView = new window.BoardView(
    model: board
    el: $board
  ).render()
  return
```

`BoardView` will take care of the rest, creating and rendering all of the
subviews needed.

If you open `index.html` in the broswer of your choice, you'll be greeted with
a functional (but so not stylish) version of a task list app with `localStorage`
persistence.

Let's add some style:

*css/style.css*

```css
/* Use border-box sizing for all elements */
* {
  box-sizing: border-box;
}

/* Make <body> occupy the full height of the window */
html, body {
  height: 100%;
}

/* The current board should cover the whole page */
.board {
  height: 100%;
  padding: 16px;
  background: #ccc;
}

/* The name of the board should go across the top of the page */
input[name=board-name] {
  font-size: 24px;
  width: 100%;
  height: 34px;
}

/* The column container should use all remaining board space */
.column-container {
  position: absolute;
  top: 62px; /* board padding-top + board-name + margin */
  bottom: 16px;
}

/* Each column should be fixed-width and use all available height */
.column {
  position: relative;
  display: inline-block;
  width: 300px;
  height: 100%;
  margin-right: 8px;
  padding: 8px;
  background: #999;
}

/* The "Add column" button should appear where the new column would go */
button[name=add-column] {
  display: inline-block;
  height: 23px;
  vertical-align: top;
}

/* The name of the column should go across the top of the column */
input[name=column-name] {
  font-size: 18px;
  width: 100%;
}

/* The card container should use all remaining column space */
.card-container {
  position: absolute;
  top: 40px; /* column padding-top + column-name + margin */
  width: 100%;
}

/* Each card should use the card-container's width and stack vertically */
.card {
  margin-right: 16px; /* padding-left + padding-right */
  margin-bottom: 8px;
  padding: 8px;

  background: #ccc;
}

/* Clearfix to ensure that we provide enough height for floated content */
.card::after {
  display: table;
  clear: both;
  content: '';
}

/* Card descriptions should be full-width (height is determined by rows) */
textarea[name=card-description] {
  width: 100%;
}

/* Each card's due date should be flush right */
.due-date-label {
  float: right;
}

/* There should be some space between the due date and its description */
input[name=due-date] {
  margin-left: 8px;
}

/* The "Add card" button should have fixed height */
button[name=add-card] {
  height: 23px;
}
```

Now, you will have something minimalist but functional.

## Tasks That Last

This is great for a single person using a single device, but in the next chapter
that will expand, and we'll build out a server for it.

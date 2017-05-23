[&lt;&lt; Back to the README](README.md)

# Chapter 3. Compiling and Running

To compile and generate the Bingo class into proper JS:

```sh
elm-make Bingo.elm --output=bingo.js
```

Next, add a `script` tag for `bingo.js` in the HTML, and then, within the HTML
`body` tag, another `script` tag, instantiating your Elm program.

```html
<script>
    Elm.Bingo.fullscreen();
</script>
```

You can also embed Elm apps into specific containers, so it doesn't need the
entire page, like it does above.

Now, when you load the page, you should see the expected message. Changing the
file will now require a recompile.

## Elm Live

Instead of dealing with constant re-compiling needs, we are going to use
`elm-live`:

```sh
elm-live Bingo.elm --open --output=bingo.js
```

The above command should open a browser window, and do live-reloading for the
page, as well.

## Embedding Elm In Elements

Quite easily done, and makes onboarding with Elm that much easier, since you
don't have to convert the entire app:

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <link rel="stylesheet" href="style.css">
    <script src="bingo.js"></script>
  </head>
  <body>
    <div id="elm-app-goes-here"></div>
    <script>
      var node = document.getElementById('elm-app-goes-here');
      var app = Elm.Bingo.embed(node);
    </script>
  </body>
</html>
```

Notice we call `Elm.Bingo.embed()` instead of `Elm.Bingo.fullscreen()`? That
enables us to assign the relevant element for embedding.

## Elm Editing Online

If you just want to check something out, you can use the Elm [online editor][elm-editor]
for it.

## Auto-Compiling with Gulp

_See notes for chapter 3 if you want details._

## Strange Behavior?

Nuke the `elm-stuff/build-artifacts` and re-compile. This fixes a plethora of
issues.

[elm-editor]: http://elm-lang.org/try
[elm-webpack]: https://github.com/elm-community/elm-webpack-loader

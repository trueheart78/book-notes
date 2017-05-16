[&lt;&lt; Back to the README](README.md)

# Chapter 2. Hello, Elm!

## Installing Project Dependencies

To make sure the relevant node-based items are installed:

```sh
npm install
```

To generate and/or install a new `elm-package.json` file:

```sh
elm package install
```

For a specific library:

```sh
elm-package install elm-lang/html
```

For a specific library version:

```sh
elm-package install elm-lang/html 3.0.1
```

## Elm Reactor

By default, Elm reactor runs on `localhost:8000`. To customize:

```sh
elm reactor --address=0.0.0.0 --port=9000
```

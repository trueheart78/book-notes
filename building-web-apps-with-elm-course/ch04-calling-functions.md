[&lt;&lt; Back to the README](README.md)

# Chapter 4. Calling Functions

```elm
String.toUpper "bingo!"
-- "BINGO!" 
```

```elm
String.repeat 3 "bingo!"
-- "bingo!bingo!bingo!"
```

```elm
String.repeat 3 (String.toUpper "bingo!")
-- "BINGO!BINGO!BINGO!"
```

These can get pretty crazy, so let's pipe instead.

```elm
"Bingo!" |> String.toUpper |> String.repeat 3 |> Html.text
-- "BINGO!BINGO!BINGO!"
```

Now, let's set that up in proper `elm-format`:

```elm
"Bingo!"
    |> String.toUpper
    |> String.repeat 3
    |> Html.text
-- "BINGO!BINGO!BINGO!"
```

## Commenting

Comments can be single-line:

```elm
-- comment
```

or multi-line:

```elm
{-

A
multi-line
comment

-}
```

[&lt;&lt; Back to the README](README.md)

# Chapter 9. Processes Have Exit Codes

When a process comes to an end, it has one last chance to make its mark on the
world: its exit code. Every process that exits does so with a numeric exit code
(0-255) denoting success or error.

**An exit code of 0 is said to be successful**.

Just handle each error code the way your program needs to, don't worry much
about what all the codes mean.

Do stick with the '0 as success' exit code tradition, so your programs will
play nicely with other Unix tools.

## How to Exit a Process.

### `exit`

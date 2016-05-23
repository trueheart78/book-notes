[&lt;&lt; Back to the README](README.md)

# Chapter 6. Real Parallel Threading with JRuby and Rubinius

JRuby and Rubinius don't have GIL. This means they *do* allow for real parallel
execution of Ruby code.

## Proof

Calculating 1 million prime numbers 10 times is a good way to see the performance
differences.

- MRI takes around 3 seconds whether in single- vs multi-threaded.
- Rubinius takes around 5 seconds in single-threaded vs 0.5 seconds multi-threaded.
- JRuby takes around 4.5 seconds in single-threaded vs 0.3 seconds multi-threaded.

## But... Don't They Need a GIL?

1. To protect internals from race conditions. Well, they do.
2. To facilitate the C extension API. JRuby just doesn't. Rubinius does.
3. To reduce likelihood of race conditions in your Ruby code. Well, they don't.

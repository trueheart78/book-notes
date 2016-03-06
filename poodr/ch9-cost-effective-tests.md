[&lt;&lt; Back to the README](README.md)

# Chapter 9. Designing Cost-Effective Tests

Writing changeable code is an art whose practice relies on three different skills.

First, you must understand object-oriented design. Poorly designed code is
naturally difficult to change. From a practical point of view, changeability is
the only design metric that matters; code that's easy to change *is* well-
designed.

Second, you must be skilled at refactoring code. And not just casually.

>  Refactoring is the process of changing a software system in such a way that
   it does not alter the external behavior of the code yet improves the internal
   structure. - Martin Fowler

Key phrase: **does not alter the external behavior of the code.**

New features will be added only after you have successfully refactored the code.
Refactoring is how you morph the current code structure into one that fits new
requirements, and is core to OOD.

If your refactoring skills are weak, improve them. Design efforts will pay full
dividends only when you can refactor with ease.

Finally, the art of writing changeable code requires the ability to write high-
value tests. Tests give you confidence to refactor constantly. Efficient tests
prove that altered code continues to behave correctly without raising overall
costs.

Well-designed code is easy to change, refactoring is how you change from one
design to the next, and tests free you to refactor with impunity.

## Intentional Testing



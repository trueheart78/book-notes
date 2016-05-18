[&lt;&lt; Back to the README](README.md)

# Chapter 4. Concurrent != Parallel

> So multiple threads will be running my code in parallel?

Concurrent doesn't mean parallel.

1. Multiple threads run your code concurrently.
2. Multiple threads might run your code in parallel.

Sequentially is one job after the other. Concurrently is managing your resources
to get two jobs done. Parallel is another person doing a separate job.

## You Can't Guarantee Anything will be Parallel

You can make it so it is concurrent, but the parallelization is left to the
thread scheduler.

You should assume it will be running in parallel, because it typically will,
but you can't guarantee it.

By making it concurrent, you enable it to be parallelized when the OS allows it.

## The Relevance

Right terms matter when discussing these ideas, and committing to things you can
control vs those you cannot is a much safer and saner way to live.

[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Modeling Your Code: Communicating Sequential Processes 🔜][upcoming-chapter]

# Chapter 1. An Introduction to Concurrency

When most people use the word "concurrent" they're usually referring to a process that occurs
simultaneoulsy with one or more processes. It's also usually implied that all of these processes are
making progress at about the same time. You are currently reading this sentence while others in the
world are simultaneously living their lives _concurrently_ to you.

## Moore's Law, Web Scale, and the Mess We're In

You've heard of Moor's Law, and it held true until 2012ish.

Amdahl's law statates that the gains are bounded by how much of the program must be written in a
sequential manner.

## Why Is Concurrency Hard?

- Race Conditions
- Atomicity
- Memory Access Synchronization
- Deadlocks, Livelocks, and Starvation
- Determining Concurrency Safety

[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Modeling Your Code: Communicating Sequential Processes 🔜][upcoming-chapter]

[readme]: README.md
[upcoming-chapter]: ch02-modeling-your-code-communicating-sequential-processes.md

[🔙 Variable Scope][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Real Numbers 🔜][upcoming-chapter]

# Chapter 5. Capstone: Ticket to Mars

Here's a challenge. Using your vast knowledge of what has been covered, you now
need to write a program to prove you can handle the Go.

The rundown:

When planning a trip to Mars, it would be handy to have ticket pricing from
multiple spacelines in one place. Use Go to create an aggregate for ticket
prices.

First goal is a prototype that generates ten random tickets and displays them
in tabular format, along with a header.

```
Spaceline        Days Round-trip Price
======================================
Virgin Galactic    23 Round-trip $  96
Virgin Galactic    39 One-way    $  37
SpaceX             31 One-way    $  41
Space Adventures   22 Round-trip $ 100
Space Adventures   22 One-way    $  50
Virgin Galactic    30 Round-trip $  84
Virgin Galactic    24 Round-trip $  94
Space Adventures   27 One-way    $  44
Space Adventures   28 Round-trip $  86
SpaceX             41 Round-trip $  72
```

The table should have four columns.

1. The spaceline
1. The trip duration to Mars
1. Whether the price covers a return trip
1. The price in _millions_

For each ticket, randomly select one of the following spacelines:

* Space Adventures
* SpaceX
* Virgin Galactic

Use a July 27, 2018 departure date, as Mars will be 57,600,000 km away from
Earth at this time.

For each ticket, randomly chose the speed the ship will travel, from 16 to 30 km/s.
This will determine the duration for the trip to Mars, as well as the price. Faster
ships should be in the $36 to $50 million range, and round trips should have their
costs doubled.

Code for this can be found [on GitHub][ticket-to-mars].

[🔙 Variable Scope][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Real Numbers 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch04-variable-scope.md
[upcoming-chapter]: ch06-real-numbers.md
[ticket-to-mars]: https://gist.github.com/trueheart78/febdab0c61759672c212429cc126a5a8

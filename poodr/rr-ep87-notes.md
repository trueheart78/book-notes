# Notes from Ruby Rogues Ep 87

**RR Book Club: Practical Object-Oriented Design in Ruby with Sandi Metz**

[View Episode](https://devchat.tv/ruby-rogues/087-rr-book-clubpractical-object-oriented-design-in-ruby-with-sandi-metz)

Don't set data, instead send messages. The '@' symbol should be used only inside getter/setter methods.

Rails users tend to be in a fair amount of pain regarding OO.

*Note: Thinks DHH is 99% right in his ideas presented on an earlier RR ep
and bets that Basecamp code is good enough*

It's a good idea to have the business logic independent of the framework.
Rails isn't the only option in town.

Frameworks are good because they can give you the most value for the least
effort.

Do what leaves you the most movement in the code in the future.

Never refer to the name of a class inside another class.
*Break glass as needed*

These techniques aren't required all the time. We tend to have more
refactoring problems and this is where the techniques are helpful.

Rules for tests are quite simple:

- Test messages going out
- Make assertions for state on incoming messages.
- Don't test private methods unless you **really** need to.
  Test the boundaries though. If you use tests to prove them out,
  *delete the tests* when you are done.
- Make tests play their role

Sad that the book only covers unit testing, so there are no integration
tests. Not enough for a Rubyist. Unit tests + integration tests should be
enough. *Controller tests are not worthwhile?*

Sandi's Rules! :heart::heart::heart:

1. Classes no bigger than 100
2. Methods no bigger than 5 lines
3. Limit parameters to 4, at most
4. Controllers should only instantiate 1 object
5. Views can only know about 1 instance variable

We're bias to staying the course. We should be breaking down large classes
and methods. Pain comes in later.

Adding a class should not be a heavyweight option. Consider inline classes to
start - Avdi

A new object needs training, of sorts. Should I be embracing the teardown
and setup? - David

Yes, David. - James + Sandi

"Too many small classes vs one big, and I don't want to deal with setup and
teardown"

- Your object is too big if you feel like it takes a lot of setup + teardown
- splitting 1 large class in half equals 2 large classes
- for a codebase out-of-control, this adds short-term complexity
- it's a matter of faith: you either believe the small objects are the right
  way to go and trust them, vs big objects.

"When do you giveup?" - Josh Susser

- If it works (and it should) start writing new code issue by issue
  and turn off the old stuff.
- Look for seems where you can make these splits
- Run Code Climate and look at the chrun cose and see if it's costing you
  money.
- It's always fixable.



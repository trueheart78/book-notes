[&lt;&lt; Back to the README](README.md)

# Chapter 8. Rails Configuration and Environments

> [Rails] gained a lot of its focus and appeal beause I didn't try to please
> people who did not share my problems. Differentiating between production and
> development was a very real problem for me, so I solved it the best way that
> I knew how.
>  - David Heinemeier Hansson

Rails apps have always been preconfigured with three standard modes of operation

1. development
1. test
1. production

These modes are basically execution environments and have a collection of
associated settings that determine things such as which database to connect to
and whether the classes of your app should be reloaded with each request. Adding
a custom environment is also simple.

The env variable of `RAILS_ENV` holds which environment you are currently in.
It corresponds to an env definition in the `config/environments` folder. Next
it checks `RACK_ENV`, and if neither is found, it defaults to `development`.

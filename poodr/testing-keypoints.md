[&lt;&lt; Back to the README](README.md)

*Pulled from Chapter 9, "Designing Cost-Effective Tests"*

**Incoming messages should be tested for the state they return. Outgoing command
messages should be tested to ensure they get sent. Outgoing query messages
should not be tested.**

It's also better for tests to assume a viewpoint that sights along the edges
of the object under tests, where they can know only about the messages that
come and go; they should know nothing internal about the object under test.

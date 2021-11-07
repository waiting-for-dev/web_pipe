# Plugs

Some groups of operations can be generalized as following the same pattern. For
example, an operation setting `Content-Type` header to `text/html` is very
similar to setting the same header to `application/json`. We name plugs to this
level of abstraction on top of operations: plugs are operation builders. In
other words, they are higher-order functions that return functions.

Being just functions, we take as a convention that plugs respond to `#call` to
create an operation.

This library ships with some useful plugs.

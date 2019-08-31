# Plugs

Some group of operations can be generalized as following same pattern. For
example, an operation setting `Content-Type` header to `text/html` is very
similar to another one setting same header to `application/json`. We name plugs
to this level of abstraction on top of operations: plugs are operation
builders. In other words, they are higher order functions which return
functions.

Being just functions, we take as convention that plugs respond to `#call` in
order to create an operation.

This library ships with some useful plugs.

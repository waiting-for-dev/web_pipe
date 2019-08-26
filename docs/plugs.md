# Plugs

Some group of operations can be generalized as following the same pattern. For
example, an operation setting the `Content-Type` header to `text/html` is very
similar to another one setting the same header to `application/json`. We name
plugs to this level of abstraction on top of operations: Plugs are operation
builders. In other words, they are higher order function which return
functions.

Being just functions, we take as convention that plugs respond to `#call` in
order to create the operation.

This library ships with some useful plugs.

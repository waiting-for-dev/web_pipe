# Design model

If you are familiar with rack you know that it models a two-way pipe. In it,
each middleware has the ability to:

- During the outbound trip modifying the request as it heads to the actual
  application.

- During the return trip modifying the response as it gets back from the
  application.

```

  --------------------->  request ----------------------->

  Middleware 1          Middleware 2          Application

  <--------------------- response <-----------------------


```

`web_pipe` follows a simpler but equally powerful model: a one-way pipe which
is abstracted on top of rack. A struct that contains data from a web request is
piped trough a stack of operations (functions). Each operation takes as
argument an instance of the struct and returns also an instance of it.
Response data can be added to the struct at any moment in the pipe.

```

  Operation 1          Operation 2          Operation 3

  --------------------- request/response ---------------->

```

Additionally, any operation in the stack can halt the propagation of the pipe,
leaving downstream operations unexecuted. In this way, final response is the
one contained in the struct at the moment the pipe was halted, or last one if
the pipe wasn't halted.

As you may know, this is the same model used by Elixir's
[`plug`](https://hexdocs.pm/plug/readme.html), from which `web_pipe` takes
inspiration.

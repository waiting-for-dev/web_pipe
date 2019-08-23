# Design model

If you are familiar with rack you know that it models a two-way pipe. In it, each middleware has the ability to:

- During the outbound trip, modify the request as it heads to the actual
  application.

- During the return trip, modify the response as it gets back from the application.

```

  --------------------->  request ----------------------->

  Middleware 1          Middleware 2          Application

  <--------------------- response <-----------------------


```

`web_pipe` follows a simpler but equally powerful model: A one-way pipe which
is abstracted on top of rack. In it, a struct that contains all the data from a
web request is piped trough a stack of operations (functions) which take it as
argument and return a new instance of it. The response data can be added to the
struct at any moment in the pipe.

```

  Operation 1          Operation 2          Operation 3

  --------------------- request/response ---------------->

```

Additionally any operation in the stack has the power to halt the propagation
of the pipe, leaving any downstream operation unexecuted. In this way, the
final response is the one contained in the struct at the moment the pipe was
halted, or the last one if it wasn't halted.

As you may know, this is the same model used by Elixir's
[`plug`](https://hexdocs.pm/plug/readme.html), from which `web_pipe` takes
inspiration.

[![Gem Version](https://badge.fury.io/rb/web_pipe.svg)](https://badge.fury.io/rb/web_pipe)
[![Build Status](https://travis-ci.com/waiting-for-dev/web_pipe.svg?branch=master)](https://travis-ci.com/waiting-for-dev/web_pipe)

# WebPipe

`web_pipe` is a rack application builder through a pipe of operations
applied to an immutable struct.

You can also think of it as a web controllers builder (the C in `MVC`)
totally declouped from the web routing (which you can still do with
something like [`hanami-router`](https://github.com/hanami/router), 
[`http_router`](https://github.com/joshbuddy/http_router) or plain
[rack's `map`
method](https://www.rubydoc.info/github/rack/rack/Rack/Builder#map-instance_method)).

If you are familiar with rack you know that it models a two-way pipe,
where each middleware in the stack has the chance to modify the
request before it arrives to the actual application, and the response
once it comes back from the application:

```

  --------------------->  request ----------------------->

  Middleware 1          Middleware 2          Application

  <--------------------- response <-----------------------


```

`web_pipe` follows a simpler but equally powerful model of a one-way
pipe and abstracts it on top of rack. A struct that contains all the
data from a web request is piped trough a stack of operations which
take it as argument and return a new instance of it where response
data can be added at any step.

```

  Operation 1          Operation 2          Operation 3

  --------------------- request/response ---------------->

```

In addition to that, any operation in the stack has the power to stop
the propagation of the pipe, leaving any downstream operation
unexecuted. This is mainly useful to unauthorize a request while being
sure that nothing else will be done to the response.

As you may know, this is the same model used by Elixir's
[`plug`](https://hexdocs.pm/plug/readme.html), from which `web_pipe`
takes inspiration.

This library has been designed to work frictionless along the
[`dry-rb`]( https://dry-rb.org/) ruby ecosystem and it uses some of
its libraries internally.

## Usage

This is a sample `config.ru` for a contrived application built with
`web_pipe`. It simply fetches a user from an `id` request
parameter. If the user is not found, it returns a not found
response. If it is found, it will unauthorize when it is a non `admin`
user or greet it otherwise:

```
rackup --port 4000
# http://localhost:4000?id=1 => Hello Alice
# http://localhost:4000?id=2 => Unauthorized
# http://localhost:4000?id=3 => Not found
```

```ruby
# config.ru
require "web_pipe"

UsersRepo = {
  1 => { name: 'Alice', admin: true },
  2 => { name: 'Joe', admin: false }
}

class GreetingAdminApp
  include WebPipe

  plug :set_content_type
  plug :fetch_user
  plug :authorize
  plug :greet

  private

  def set_content_type(conn)
    conn.add_response_header(
      'Content-Type', 'text/html'
    )
  end

  def fetch_user(conn)
    user = UsersRepo[conn.params['id'].to_i]
    if user
      conn.
        put(:user, user)
    else
      conn.
        set_status(404).
        set_response_body('<h1>Not foud</h1>').
        taint
    end
  end

  def authorize(conn)
    if conn.fetch(:user)[:admin]
      conn
    else
      conn.
        set_status(401).
        set_response_body('<h1>Unauthorized</h1>').
        taint
    end
  end
  
  def greet(conn)
    conn.
      set_response_body("<h1>Hello #{conn.fetch(:user)[:name]}</h1>")
  end
end

run GreetingAdminApp.new
```

As you see, steps required are:

- Include `WebPipe` in a class.
- Specify the stack of operations with `plug`.
- Implement those operations.
- Initialize the class to obtain resulting rack application.

`WebPipe::Conn` is a struct of request and response date, seasoned
with methods that act on its data. These methods are designed to
return a new instance of the struct each time, so they encourage
immutability and make method chaining possible.

Each operation in the pipe must accept a single argument of a
`WebPipe::Conn` instance and it must also return an instance of it.
In fact, what the first operation in the pipe takes is a
`WebPipe::Conn::Clean` subclass instance. When one of your operations
calls `#taint` on it, a `WebPipe::Conn::Dirty` is returned and the pipe
is halted. This one or the 'clean' instance that reaches the end of
the pipe will be in command of the web response.

Operations have the chance to prepare data to be consumed by
downstream operations. Data can be added to the struct through
`#put(key, value)`, while it can be consumed with `#fetch(key)`.

Attributes and methods in `WebPipe::Conn` are [fully
documented](https://www.rubydoc.info/github/waiting-for-dev/web_pipe/master/WebPipe/Conn).

### Specifying operations

There are several ways you can `plug` operations to the pipe:

#### Instance methods

Operations can be just methods defined in the pipe class. This is what
you saw in the previous example:

```ruby
class App
  include WebPipe

  plug :hello

  private

  def hello(conn)
    # ...
  end
```

#### Proc (or anything responding to `#call`)

Operations can also be defined inline as anything that responds to
`#call`, like a `Proc`, or also like a block:

```ruby
class App
  include WebPipe

  plug :hello, ->(conn) { conn }
  plug(:hello2) { |conn| conn }
end
```

The representation of a `WebPipe` as a Proc is itself an operation
accepting a `Conn` and returning a `Conn`: the composition of all its
plugs. Therefore, it can be plugged to any other `WebPipe`:

```ruby
class HtmlApp
  include WebPipe

  plug :html

  private

  def html(conn)
    conn.add_response_header('Content-Type', 'text/html')
  end
end

class App
  include WebPipe

  plug :html, HtmlApp.new
  plug :body

  private

  def body(conn)
     conn.set_response_body('Hello, world!')
  end
end
```

#### Container

When a `String` or a `Symbol` is given, it can be used as the key to
resolve an operation from a container. A container is just anything
responding to `#[]`.

The container to be used is configured when you include `WebPipe`:

```ruby
class App
  Container = Hash[
    'plugs.hello' => ->(conn) { conn }
  ]

  include WebPipe.(container: Container)

  plug :hello, 'plugs.hello'
end
```

### Operations injection

Operations can be injected when the application is initialized,
overriding those configured through `plug`:

```ruby
class App
  include WebPipe

  plug :hello, ->(conn) { conn.set_response_body('Hello') }
end

run App.new(plugs: {
    hello: ->(conn) { conn.set_response_body('Injected') }
  }
)
```

In the previous example, resulting response body would be `Injected`.

### Rack middlewares

Rack middlewares can be added to the generated application through
`use`. They will be executed in declaration order before the pipe of
plugs:

```ruby
class App
  include WebPipe

  use :middleware_1, Middleware1
  use :middleware_1, Middleware2, option_1: value_1

  plug :hello, ->(conn) { conn }
end
```

It is also possible to compose all the middlewares from another pipe
class. Extending from previous example:

```ruby
class App2
  include WebPipe

  use :app, App.new # it will also use Middleware1 and Middleware2

  plug :hello, ->(conn) { conn }
end
```

Middlewares can also be injected on initialization:

```ruby
App.new(middlewares: {
  middleware_1: [AnotherMiddleware, options]
})
```

### Standalone usage

If you prefer, you can use the application builder without the
DSL. For that, you just have to initialize a `WebPipe::App` with an
array of all the operations to be performed:

```ruby
require 'web_pipe/app`

op_1 = ->(conn) { conn.set_status(200) }
op_2 = ->(conn) { conn.set_response_body('Hello') }

WebPipe::App.new([op_1, op_2])
```

## Plugs

`web_pipe` ships with a series of common operations you can take
advantage in order to build your application:

- [container](lib/web_pipe/plugs/container.rb): Allows
  configuring a container to resolve dependencies.
- [content_type](lib/web_pipe/plugs/content_type.rb): Sets
  `Content-Type` response header.

## Extensions

By default, `web_pipe` behavior is the very minimal you need to build
a web application. However, you can extend it with the following
extensions (click on each name for details on the usage):

- [dry-view](lib/web_pipe/extensions/dry_view/dry_view.rb):
  Integration with [`dry-view`](https://dry-rb.org/gems/dry-view/)
  rendering system.

## Current status

`web_pipe` is in active development. The very basic features to build
a rack application are all available. However, very necessary
conveniences to build a production application, for example a session
mechanism, are still missing.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/waiting-for-dev/web_pipe.

## Release Policy

`web_pipe` follows the principles of [semantic versioning](http://semver.org/).
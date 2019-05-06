# WebPipe

WebPipe is a rack application builder through a pipe of operations
applied to an immutable struct.

You can also think of it as a web controllers builder (the C in `MVC`)
totally declouped from the web routing (which you can still do with
something like [`hanami-router`](https://github.com/hanami/router) or
[`http_router`](https://github.com/joshbuddy/http_router)).

The design principles kept in mind while developing it are:

- Immutability.
- Type safety (at the extend ruby can allow, thanks to
  [`dry-types`](https://dry-rb.org/gems/dry-types).
- Functional Objects.
- IoC containers and dependency injection.
- Simplicity.

If you are familiar with rack you know that it models a two-way pipe,
where each middleware in the stack has the chance to modify the
request before it arrives to the actual application, and the response
once it comes back from the application:

```

  --------------------->  request ----------------------->

  Middleware 1          Middleware 2          Application

  <--------------------- response <-----------------------


```

WebPipe follows a simpler but equally powerful model of a one-way pipe
and abstracts it on top of rack. A struct wich contains all the data from a web
request is piped trough a stack of operations which take it as argument and
return a new instance of it where response data can be added at any step.

```

  Operation 1          Operation 2          Operation 3

  --------------------- request/response ---------------->

```

In addition to that, any operation in the stack has the power to stop
the propagation of the pipe, leaving any operation downstream
unexecuted. This is mainly useful to unauthorize a request and to be
sure that nothing else will be done to the response.

As you may know, this is the same model used by Elixir's
[`plug`](https://hexdocs.pm/plug/readme.html), from which `Web_Pipe`
takes inspiration.

This library has been designed to be frictionless with the [`dry-rb`](
https://dry-rb.org/) ruby ecosystem and it uses some of its libraries
internally.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'web_pipe', github: 'waiting-for-dev/web_pipe'
```

And then execute:

    $ bundle

## Usage

This is a sample `config.ru` for an application built with
`WebPipe`. It just reads a `name` param and decides what to do with
it. If its value is `Joe`, it kindly greets `Joe Doe`, otherwise it
unauthorizes the request:

```ruby
require 'web_pipe'

class App
  include WebPipe

  plug :authorize
  plug :greet

  private

  def authorize(conn)
    if conn.params['name'] == 'Joe'
      conn.put(:name, 'Joe Doe')
    else
      conn.
        set_status(401).
        add_response_header('Content-Type', 'text/plain').
        set_response_body('Unauthorized').
        taint
    end
  end
    
  def greet(conn)
    conn.
      set_response_body("<h1>Hello #{conn.fetch(:name)}</h1>").
      add_response_header('Content-Type', 'text/html')
  end
end

run App.new
```

As you see, the workflow is:

- Include `WebPipe` in a class.
- Specify the stack of operations with `plug`.
- Implement these operations.
- Initialize the class to obtain the resulting rack application.

Each operation takes a `WebPipe::Conn` as argument and returns it
usually with some modification. In fact, the first operation in your
pipe takes a `WebPipe::Conn::Clean` subclass. When one of your
operations call `#taint` on it a `WebPipe::Conn::Dirty` is returned
and the pipe is halted. This one or the last clean struct which
reaches the end of the pipe will be in command of the web response.

At any step in the pipe, you have the option to prepare data to be
consumed downstream. You do so by calling `#put` in the struct, while
it can later be accesed with `#fetch`.

### Specifying operations

There are several ways you can `plug` operations to the pipe:

#### Instance methods

This is what you saw in the previous example:

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

You can also specify the operation inline with the `with:` keyword and
anything that responds to `#call`, like a `Proc`:

```ruby
class App
  include WebPipe

  plug :hello, with: ->(conn) { conn }
end
```

#### Container key

When `with:` is a `String` or a `Symbol`, it can be used as a key to
resolve something callable from a container of operations (a container
is anything responding to `#[]`).

The container to use is set when you include `WebPipe` module:

```ruby
class App
  Container = Hash[
    'plugs.hello' => ->(conn) { conn }
  ]

  include WebPipe.(container: Container)

  plug :hello, with: 'plugs.hello'
end
```

### Injecting operations

Configured operations can be injected when the application is initialized:

```ruby
class App
  include WebPipe

  plug :hello, with: ->(conn) { conn.set_response_body('Hello') }
end

run App.new(hello: ->(conn) { conn.set_response_body('Injected') })
```

In the example, the response body would be `Injected`.

### Rack middlewares

Rack middlewares can be added to the resulting application through
`use`. They will be executed in declaration order before the pipe of
plugs:

```ruby
class App
  include WebPipe

  use Middleware1
  use Middleware2, option_1: value_1

  plug :hello, with: ->(conn) { conn }
end
```

### Standalone usage

If you prefer, you can use the application builder without the
DSL. You just have to initialize a `WebPipe::App` with an array
with all the operations to be performed:

```ruby
require 'web_pipe/app`

op_1 = ->(conn) { conn.set_status(200) }
op_2 = ->(conn) { conn.set_response_body('Hello') }

WebPipe::App.new([op_1, op_2])
```

## Current status

`web_pipe` is in active development. The very basic features to build
a rack application are all available. However, conveniences to build a
production application are still missing.

## Development

After checking out the repo, run `bin/setup` to install
dependencies. Then, run `rake spec` to run the tests. You can also run
`bin/console` for an interactive prompt that will allow you to
experiment.

To install this gem onto your local machine, run `bundle exec rake
install`. To release a new version, update the version number in
`version.rb`, and then run `bundle exec rake release`, which will
create a git tag for the version, push git commits and tags, and push
the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/waiting-for-dev/web_pipe.

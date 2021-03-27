# Inspecting middlewares

Once a `WebPipe` class is initialized all its middlewares get resolved. They
can be accessed through the `#middlewares` method.

Each middleware is represented by a
`WebPipe::RackSupport::MiddlewareSpecification` instance, which contains two
accessors: `middleware` returns the middleware class, while `options` returns
an array with the arguments that are provided to the middleware on initialization.

Kepp in mind that every middleware is resolved as an array. This is because it
can in fact be composed by an chain of middlewares built through
[composition](composing_middlewares.md).


```ruby
require 'web_pipe'
require 'rack/session'

class MyApp
  include WebPipe
  
  use :session, Rack::Session::Cookie, key: 'my_app.session', secret: 'long'

  plug(:hello) do |conn|
    conn.set_response_body('Hello world!')
  end
end

app = MyApp.new
session_middleware = app.middlewares[:session][0]
session_middleware.middleware # => Rack::Session::Cookie
session_middleware.options # => [{ key: 'my_app.session', secret: 'long' }]
```

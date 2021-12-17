# Overriding instance methods

You can override the included instance methods and use `super` to delegate to
the `WebPipe`'s implementation.

For instance, you might want to add some behavior to your initializer. However,
consider that you need to dispatch the arguments that `WebPipe` needs. Example:

```ruby
class MyApp
  include WebPipe

  attr_reader :body

  def initialize(body:, **kwargs)
    @body = body
    super(**kwargs)
  end

  plug :render

  private

  def render(conn)
    conn.set_response_body(body)
  end
end
```

The same goes with any other instance method, like Rack's interface:

```ruby
class My App
  include WebPipe

  plug :render

  def render(conn)
    conn.set_response_body(conn.env['body'])
  end

  def call(env)
    env['body'] = 'Hello, world!'
    super
  end
end
```

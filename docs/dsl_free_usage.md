# DSL free usage

DSL's (like the one in `web_pipe` with class methods like `plug` or
`use`) provide developers with a user-friendly way to
use a library. However, they usually come at the expense of increasing
complexity in internal code (which sooner than later translates into some
issue).

`web_pipe` has tried to make an extra effort to minimize these problems. For
this reason, the DSL in this library is just a layer providing convenience on
top of the independent core functionality.

The DSL methods delegate transparently to instances of `WebPipe::Pipe`, so you
can also work directly with them and forget about magic.

For instance, the following rack application written through the DSL:

```ruby
# config.ru
require 'web_pipe'

WebPipe.load_extensions(:params)

class HelloApp
  include WebPipe

  plug :fetch_name
  plug :render

  private

  def fetch_name(conn)
    conn.add(:name, conn.params['name'])
  end

  def render(conn)
    conn.set_response_body("Hello, #{conn.fetch(:name)}!")
  end
end

run HelloApp.new
```

is exactly equivalent to:

```ruby
# config.ru
require 'web_pipe'

WebPipe.load_extensions(:params)

app = WebPipe::Pipe.new
                   .plug(:fetch_name, ->(conn) { conn.add(:name, conn.params['name']) })
                   .plug(:render, ->(conn) { conn.set_response_body("Hello, #{conn.fetch(:name)}") })

run app
```

As you see, the instance of `WebPipe::Pipe` is itself the rack application.

You can provide a context object to resolve methods when only a name is given
on `#plug`:

```ruby
class Context
  def fetch_name(conn)
    conn.add(:name, conn.params['name'])
  end

  def render(conn)
    conn.set_response_body("Hello, #{conn.fetch(:name)}")
  end
end

app = WebPipe::Pipe.new(context: Context.new)
                   .plug(:fetch_name)
                   .plug(:render)

run app
```

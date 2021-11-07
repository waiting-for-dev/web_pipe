# Inspecting operations

Once a `WebPipe` class is initialized, all its operations get resolved. It
happens because they are whether [resolved](resolving_operations.md) or
[injected](injecting_operations.md). The final result can be accessed through
the `#operations` method:

```ruby
require 'web_pipe'
require 'web_pipe/conn_support/builder'

class MyApp
  include WebPipe

  plug(:hello) do |conn|
    conn.set_response_body('Hello world!')
  end
end

app = MyApp.new
conn = WebPipe::ConnSupport::Builder.call(Rack::MockRequest.env_for)
new_conn = app.operations[:hello].call(con)
conn.response_body #=> ['Hello world!']
```

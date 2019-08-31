# Injecting operations

Operations can be injected at the moment an application is initialized,
which allows you to override what the definition declares.

To this effect, you must use `plugs:` keyword argument. It must be a hash where
operations are matched by the name you gave them in its definition.

This is mainly useful for testing purposes, where you can switch a heavy
operation and use another lighter one.

In the following example, the response body of the application will be
`'Hello from injection'`:

```ruby
# config.ru
require 'web_pipe'

class MyApp
  include WebPipe
  
  plug(:hello) do |conn|
    conn.set_response_body('Hello from definition')
  end
end

injection = lambda do |conn|
  conn.set_response_body('Hello from injection')
end

run MyApp.new(plugs: { hello: injection })
```

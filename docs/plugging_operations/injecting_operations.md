# Injecting operations

Operations can be injected at the moment the application is initialized,
allowing you to override what you plugged in the definition.

For that, you use the `plugs:` keyword argument, which must be a hash where
operations are matched by the name you gave them in the definition.

This is mainly useful for testing purposes, where you can switch a heavy
operation and use something lighter.

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

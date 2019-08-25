# Injecting middlewares

Middlewares can be injected at the moment the application is initialized,
allowing you to override what you had defined in the DSL.

For that, you use the `middlewares:` keyword argument, which must be a hash
where middlewares are matched by the name you gave them in the definition.

The middleware must be specified as an Array. First item in it must be the
injected rack middleware class, while the rest of arguments (if any) must be
the options it needs.

This is mainly useful for testing purposes, where you can switch a heavy
middleware and use a mocked one instead.

In the following example, rack session mechanism is being mocked:

```ruby
# config.ru
require 'web_pipe'
require 'rack/session/cookie'

class MyApp
  include WebPipe
  
  use :session, Rack::Session::Cookie, key: 'my_app.session', secret: 'long'
  
  plug(:serialize_session) do |conn|
    conn.set_response_body(conn.env['rack.session'].inspect)
  end
end

class MockedSession
  attr_reader :app, :key
  
  def initialize(app, key)
    @app = app
    @key = key
  end
  
  def call(env)
    env['rack.session'] = "Mocked for '#{key}' key"
  end
end

run MyApp.new(middlewares: { session: [MockedSession, 'my_app_mocked'] })
```

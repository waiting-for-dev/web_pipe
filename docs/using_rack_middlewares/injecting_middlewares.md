# Injecting middlewares

Middlewares can be injected at the moment an application is initialized,
allowing you to override what you have defined in the DSL.

For that purpose, you have to use `middlewares:` keyword argument. It must be a
hash where middlewares are matched by the name you gave them in its definition.

A middleware must be specified as an `Array`. First item must be a rack
middleware class. The rest of arguments (if any) should be any option it may
need.

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

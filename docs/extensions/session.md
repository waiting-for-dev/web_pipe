# Session

Wrapper around `Rack::Session` middleware to help working with
sessions in your plugged operations.

It depends on `Rack::Session` middleware, which is shipped by rack.

It adds following methods to `WebPipe::Conn`:

- `#fetch_session(key)`, `#fetch_session(key, default)` or
  `#fetch_session(key) { default }`. Returns what is stored under
  given session key. A default value can be given as a second
  argument or a block.
- `#add_session(key, value)`. Adds given key/value pair to the
  session.
- `#delete_session(key)`. Deletes given key from the session.
- `#clear_session`. Deletes everything from the session.

```ruby
require 'web_pipe'
require 'rack/session'

WebPipe.load_extensions(:session)

class MyApp
  include WebPipe
  
  use Rack::Session::Cookie, secret: 'top_secret'
  
  plug(:add_to_session) do |conn|
    conn.add_session('foo', 'bar')
  end
  plug(:fetch_from_session) do |conn|
    conn.add(
      :foo, conn.fetch_session('foo')
    )
  end
end
```

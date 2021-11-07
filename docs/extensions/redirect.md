# Redirect

This extension helps create a redirect response.

Redirect responses consist of two pieces:

- The `Location` response header with the URL to which browsers should
  redirect.
- A 3xx status code.

A `#redirect(location, code)` method is added to `WebPipe::Conn`, which takes
care of both steps. The `code` argument is optional, defaulting to `302`.

```ruby
require 'web_pipe'

WebPipe.load_extensions(:redirect)

class MyApp
  include WebPipe

  plug(:redirect) do |conn|
    conn.redirect('/')
  end
end
```

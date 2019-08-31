# Flash

This extension provides with typical flash messages functionality. Messages for
users are stored in session in order to be consumed by another request after a
redirect.

This extension depends on
[`Rack::Flash`](https://rubygems.org/gems/rack-flash3) (gem name is
`rack-flash3`) and `Rack::Session` (shipped with rack) middlewares.

`WebPipe::Conn#flash` contains the flash bag. In order to add a message to it,
you can use `#add_flash(key, value)` method.

There is also an `#add_flash_now(key, value)` method, which is used to add a
message to the bag with the intention for it to be consumed in the current
request. Be aware that it is in fact a coupling with the view layer.
Something that has to be consumed in the current request should be just data
given to the view layer, but it helps when it can treat both scenarios as flash
messages.

```ruby
require 'web_pipe'
require 'rack/session/cookie'
require 'rack-flash'

WebPipe.load_extensions(:flash)

class MyApp
  include WebPipe

  use :session, Rack::Session::Cookie, secret: 'secret'
  use :flash, Rack::Flash

  plug :add_to_flash, ->(conn) { conn.add_flash(:notice, 'Hello world') }
  
  # Usually you will end up making `conn.flash` available to your view
  # system:
  #
  # <div class="notice"><%= flash[:notice] %></div>
 end
```

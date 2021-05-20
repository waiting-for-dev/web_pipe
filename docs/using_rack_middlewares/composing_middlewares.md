# Composing middlewares

In a similar way that you compose plugged operations, you can also compose rack
middlewares from another application.

For that, you just need to `use` another application. All the middlewares for
that application will be added to the stack in the same order.

```ruby
class HtmlApp
  include WebPipe
  
  use :session, Rack::Session::Cookie, key: 'my_app.session', secret: 'long'
  use :csrf, Rack::Csrf, raise: true
end

class MyApp
  include WebPipe
  
  use :html, HtmlApp.new
  # use ...
  
  # plug ...
end
```

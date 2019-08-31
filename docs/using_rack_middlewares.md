# Using rack middlewares

A one-way pipe like the one `web_pipe` implements can deal with any required
feature in a web application. However, usually it is convenient to be able to
use some well-known rack middleware so you don't have to reinvent the wheel.
Even if you can add them at the router layer, `web_pipe` allows you to
encapsulate them in your application definition.

In order to add rack middlewares to the stack, you have to use the DSL method
`use`. The first argument it takes is a `Symbol` with the name you want to
assign to it (which is needed to allow
[injection](/docs/using_rack_middlewares/injecting_middlewares.md) on
initialization). Then, it must follow the middleware class and any option it
may need:

```ruby
class MyApp
  include WebPipe
  
  use :cookies, Rack::Session::Cookie, key: 'my_app.session', secret: 'long'
end
```

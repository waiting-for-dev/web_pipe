# Using rack middlewares

A one-way pipe like the one `web_pipe` implements can deal with any required
feature in a web application. However, usually it is convenient to be able to
use some well known rack middlewares in order not to reinvent the wheel. Even
if you can add them at the router layer, `web_pipe` allows you to encapsulate
them with your application definition.

In order to add rack middlewares to the stack, you have to use the DSL method
`use`. The first argument it takes is a symbol with the name you want to give
to the middleware (needed to allow injection on initialization). Then, it
follows the middleware class and any option it may need:

```ruby
class MyApp
  include WebPipe
  
  use :cookies, Rack::Session::Cookie, key: 'my_app.session', secret: 'long'
end
```

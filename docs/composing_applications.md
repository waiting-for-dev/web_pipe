# Composing applications

Previously, we have seen how to [compose plugged
operations](plugging_operations/composing_operations.md) and how to [compose
rack middlewares](using_rack_middlewares/composing_middlewares.md). The logical
next step is composing `web_pipe` applications, which is the same as composing
operations and middlewares simultaneously.

The DSL method `compose` does precisely that:

```ruby
class HtmlApp
  include WebPipe
  
  use :session, Rack::Session::Cookie, key: 'my_app.session', secret: 'long'
  use :csrf, Rack::Csrf, raise: true
  
  plug :content_type
  plug :default_status
  
  private
  
  def content_type(conn)
    conn.add_response_header('Content-Type' => 'text/html')
  end
  
  def default_status(conn)
    conn.set_status(404)
  end
end

class MyApp
  include WebPipe
  
  compose :web, HtmlApp.new
  # It does exactly the same as:
  # use :web, HtmlApp.new
  # plug :web, HtmlApp.new
  
  # use ...
  # plug ...
end
```

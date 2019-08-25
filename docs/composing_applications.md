# Composing applications

Previously, we have seen how to compose plugged operations and how to compose
rack middlewares. The logical next step is thinking about composing `web_pipe`
applications, which is exactly the same as composing both operations and
middlewares at the same time.

The DSL method `compose` does exactly that:

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
  # It does exactly the same than:
  # use HtmlApp.new
  # plug HtmlApp.new
  
  # use ...
  # plug ...
end
```

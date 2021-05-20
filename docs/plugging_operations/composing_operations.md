# Composing operations

As we already have said, operations are functions taking a connection struct
and returning a connection struct. As a result, a composition of operations is
an operation in itself (as it also takes a connection struct and returns a
connection struct).

We can leverage that to plug a whole `web_pipe` application as an operation to
another application. By doing so, you are plugging an operation which is the
composition of all operations for a given application.

```ruby
class HtmlApp
  include WebPipe
  
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
  
  plug :html, HtmlApp.new
  # plug ...
end
```

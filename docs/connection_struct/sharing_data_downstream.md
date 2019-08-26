# Sharing data downstream

Usually you'll need to prepare some data in one operation with the
intention for it to be consumed by another downstream operation.
The connection struct has a `#bag` attribute which is useful for
this purpose.

`WebPipe::Conn#bag` is a `Hash` with `Symbol` keys where values can
be anything you need to share. To help with the process we have following methods:

- `#add(key, value)`: Assigns a value to a key.
- `#fetch(key)`, `#fetch(key, default)`: Retrieves value associated
  to given key. If it is not found, `default` is returned when
  provided.

This is a simple example of a web application which reads a `name`
parameter and normalizes it before using it in the response body.

```ruby
# config.ru
require 'web_pipe'

WebPipe.load_extensions(:params)

class NormalizeNameApp
  include WebPipe
  
  plug :normalize_name
  plug :respond
  
  private
  
  def normalize_name(conn)
    conn.add(
      :name, conn.params[:name].downcase.capitalize
    )
  end
  
  def respond(conn)
    conn.set_response_body(
      conn.fetch(:name)
    )
  end
end

run NormalizeNameApp.new
```

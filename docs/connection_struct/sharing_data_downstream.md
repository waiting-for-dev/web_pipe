# Sharing data downstream

Usually, you'll find the need to prepare some data in one operation with the
intention for it to be consumed by another downstream operation. The connection
struct has a `#bag` attribute which is helpful for this purpose.

`WebPipe::Conn#bag` is a `Hash` with `Symbol` keys where the values can be
anything you need to share. To help with the process, we have the following
methods:

- `#add(key, value)`: Assigns a value to a key.
- `#fetch(key)`, `#fetch(key, default)`: Retrieves the value associated
  to a given key. If it is not found, `default` is returned when
  provided.

This is a simple example of a web application that reads a `name`
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

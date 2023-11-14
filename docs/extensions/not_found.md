# Not found

This extension helps to build a not-found response in a single method
invocation. The `WebPipe::Conn#not_found` method will:

- Set 404 as response status.
- Set 'Not found' as the response body, or instead run a step configured in
`:not_found_body_step` config key.
- Halt the connection struct.

```ruby
require 'web_pipe'

WebPipe.load_extensions(:params, :not_found)

class ShowItem
  include 'web_pipe'

  plug :config, WebPipe::Plugs::Config.(
    not_found_body_step: ->(conn) { conn.set_response_body('Nothing') }
  )

  plug :fetch_item do |conn|
    conn.add(:item, Item[params['id']])
  end

  plug :check_item do |conn|
    if conn.fetch(:item)
      conn
    else
      conn.not_found
    end
  end

  plug :render do |conn|
    conn.set_response_body(conn.fetch(:item).name)
  end
end
```

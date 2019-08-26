# Container

`:container` is a very simple extension which allows you to configure a
dependency injection container to be accessible from the `WebPipe::Conn`
instance.

The container to use must be configured under the `:configuration` key, and it
will be accessible though the `#container` method.

You may be thinking why you should worry about configuring a container for the
connection instance when you already have access to the container configured
for the application (from where you can resolve plugged operations). The idea
here is decoupling the operations from the application DSL. If at sometime you
decide to get rid off the DSL, the process will be straightforward if
operations are using the container configured in the connection instance.

```ruby
require 'web_pipe'
require 'web_pipe/plugs/config'
require 'my_container'

WebPipe.load_extensions(:container)

class MyApp
  include WebPipe.(container: MyContainer)
  
  plug :config, WebPipe::Plugs::Config.(
    container: MyContainer
  )
  plug :this, :this # Resolved thanks to the container in `include`
  plug :that
  
  private
  
  def that(conn)
    conn.set_response_body(
      conn.container['do'].() # Resolved thanks to the container in `:config`
    )
  end
end
```

# Container

`:container` is a very simple extension which allows you to configure a
dependency injection container to be accessible from a `WebPipe::Conn`
instance.

The container to use must be configured under `:configuration` key. It will be
accessible through the `#container` method.

You may be thinking why you should worry about configuring a container for a
connection instance when you already have access to the container configured
for an application (from where you can resolve plugged operations). The idea
here is decoupling operations from application DSL. If at anytime in the future
you decide to get rid off the DSL, the process will be straightforward if
operations are using the container configured in a connection instance.

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

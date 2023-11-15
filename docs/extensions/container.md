# Container

`:container` is a simple extension that allows you to configure a dependency
injection container to be accessible from a `WebPipe::Conn` instance.

The container to use must be configured under the `:container` config key. It
will be accessible through the `#container` method.

Although you'll usually want to configure the container in the application
class (for instance, using
[dry-system](https://dry-rb.org/gems/dry-system/main/)), having it at the
connection struct level is useful for building other extensions that may need
to access to it, like the [`hanami_view`](hanami_view.md) one.

```ruby
require 'web_pipe'
require 'my_container'

WebPipe.load_extensions(:container)

class MyApp
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

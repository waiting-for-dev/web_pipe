# Router params

This extension can be used to merge placeholder parameters
that usually routers support (like `get /users/:id`) to the parameters hash
added through the [`:params` extension](params.md) (which is
automatically loaded if using `:router_params`).

This extension adds a transformation function named `:router_params`to the
registry. Internally, it merges what is present in rack env's
`router.params` key.

It automatically integrates with
[`hanami-router`](https://github.com/hanami/router).

Don't forget that you have to add yourself the `:router_params`
transformation to the stack.

```ruby
require 'web_pipe'
require 'web_pipe/plugs/config'

WebPipe.load_extensions(:router_params)

class MyApp
  include WebPipe

  plug :config, WebPipe::Plugs::Config.(
    param_transformations: [:router_params, :deep_symbolize_keys]
  )
  plug :this

  private

  def this(conn)
    # http://example.com/users/1/edit
    conn.params # => { id: 1 }
    # ...
  end
end
```

# Params

This extension adds a `WebPipe::Conn#params` method which returns
request parameters as a Hash where any number of transformations
can be configured.

When no transformations are configured, `#params` just returns GET and POST parameters as a hash:

```ruby
# http://www.example.com?foo=bar
conn.params # => { 'foo' => 'bar' }
```

You can configure a stack of transformations to be applied to the
parameter hash. For that, we lean on [`transproc`
gem](https://github.com/solnic/transproc) (you have to add it yourself to your
Gemfile). All hash transformations in `transproc` are available by default.

Transformations must be configured under `:param_transformations`
key:

```ruby
require 'web_pipe'
require 'web_pipe/plugs/config'

WebPipe.load_extensions(:params)

class MyApp
  incude WebPipe
  
  plug :config, WebPipe::Plugs::Config.(
    param_transformations: [:deep_symbolize_keys]
  )

  plug(:this) do |conn|
    # http://www.example.com?foo=bar
    conn.params => # => { foo: 'bar' }
    # ...
  end
end
```

Extra needed arguments can be provided as an array:

```ruby
# ...
plug :config, WebPipe::Plugs::Config.(
  param_transformations: [
    :deep_symbolize_keys, [:reject_keys, [:zoo]]
  ]
)

plug(:this) do |conn|
  # http://www.example.com?foo=bar&zoo=zoo
  conn.params => # => { foo: 'bar' }
  # ...
end
# ...
```

Custom transformations can be registered in `WebPipe::Params::Transf` `transproc` register:

```ruby
fake = ->(_params) { { fake: :params } }
WebPipe::Params::Transf.register(:fake, fake)

# ...
plug :config, WebPipe::Plugs::Config.(
  param_transformations: [:fake]
)

plug(:this) do |conn|
  # http://www.example.com?foo=bar
  conn.params => # => { fake: :params }
  # ...
end
# ...
```

Your own transformation functions can depend on the `WebPipe::Conn`
instance at the moment of calling `#params`. Those functions must accept
the connection struct as its last argument:

```ruby
add_name = ->(params, conn) { params.merge(name: conn.fetch(:name)) }
WebPipe::Params::Transf.register(:add_name, add_name)

# ...
plug :config, WebPipe::Plugs::Config.(
  param_transformations: [:deep_symbolize_keys, :add_name]
)

plug(:add_name) do |conn|
  conn.add(:name, 'Alice')
end

plug(:this) do |conn|
  # http://www.example.com?foo=bar
  conn.params => # => { foo: :bar, name: 'Alice' }
  # ...
end
# ...
```
Finally, you can override configured transformations injecting another set at the moment of calling `#params`:

```ruby
# ...
plug :config, WebPipe::Plugs::Config.(
  param_transformations: [:deep_symbolize_keys]
)

plug(:this) do |conn|
  # http://www.example.com?foo=bar&zoo=zoo
  conn.params([:reject_keys, ['zoo']]) => # => { 'foo' => 'zoo' }
  # ...
end
# ...

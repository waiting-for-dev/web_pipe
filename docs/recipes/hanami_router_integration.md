# hanami-router integration

A `web_pipe` application instance is a rack application.
Consequently, you can mount it with `hanami-router`'s' `to:`
option.

```ruby
# config.ru
require 'hanami/router'
require 'web_pipe'

class MyApp
  include WebPipe
  
  plug :this, ->(conn) { conn.set_response_body('This') }
end

router = Hanami::Router.new do
  get 'my_app', to: MyApp.new
end

run router
```

In order to perform [string matching with variables](https://github.com/hanami/router#string-matching-with-variables) you just need to load [`:router_params` extension](/docs/extensions/router_params.md).

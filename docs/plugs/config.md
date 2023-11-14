# Config

The `Config` plug helps in adding configuration settings (`#config` hash
attribute) to an instance of `WebPipe::Conn`.

```ruby
require 'web_pipe'

class MyApp
  include WebPipe
  
  plug :config, WebPipe::Plugs::Config.(
    key1: :value1,
    key2: :value2
  )
end
```

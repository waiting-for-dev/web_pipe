# Config

`Config` plug helps in the addition of configuration settings (`#config` hash
attribute) to an instance of `WebPipe::Conn`.

```ruby
require 'web_pipe'
require 'web_pipe/plugs/config'

class MyApp
  include WebPipe
  
  plug :config, WebPipe::Plugs::Config.(
    key1: :value1,
    key2: :value2
  )
end
```

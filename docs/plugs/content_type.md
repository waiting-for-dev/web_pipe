# ContentType

`ContentType` plug is just a helper to set `Content-Type` response header.

Example:

```ruby
require 'web_pipe'
require 'web_pipe/plugs/content_type'

class MyApp
  include WebPipe
  
  plug :html, WebPipe::Plugs::ContentType.('text/html')
end
```

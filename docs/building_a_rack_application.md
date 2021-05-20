# Building a rack application

To build a rack application with `web_pipe`, you have to include
`WebPipe` module in a class:

```ruby
require 'web_pipe'

class MyApp
  include WebPipe

  # ...
end
```

Then, you can plug the operations and add the rack middlewares you need.

The instance of that class will be the rack application:

```ruby
# config.ru
require 'my_app'

run MyApp.new
```

# Building a rack application

In order to build a rack application with `web_pipe` you need to include
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

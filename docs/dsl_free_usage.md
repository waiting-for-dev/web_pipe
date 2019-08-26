# DSL free usage

DSL's (like the one in `web_pipe` with methods like `plug` or
`use`) provide developers with a user friendly and ergonomic way to
use a library. However, it usually comes at expenses of increasing
complexity in internal code (which sooner than later translates
into some kind of issue.)

`web_pipe` has tried to do an extra effort to minimize these
problems. For this reason, the DSL in this library is just a layer
on top of the independent core functionality.

To use `web_pipe` without its DSL layer, you just need to initialize a `WebPipe::App` instance with an array of all the operations that otherwise you'd `plug`. That instance will be a rack application ready to use.

```ruby
# config.ru
require 'web_pipe/app'

op_1 = ->(conn) { conn.set_status(200) }
op_2 = ->(conn) { conn.set_response_body('Hello, World!') }

app = WebPipe::App.new([op_1, op_2])

run app
```

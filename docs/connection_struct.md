# Connection struct

The first operation you plug in a `web_pipe` application receives an instance of
`WebPipe::Conn` automatically created.

`WebPipe::Conn` is just a struct data type that contains all the information
from the current web request. In this regard, you can think of it as a
structured rack's env hash.

Request related attributes of this struct are:

- `#scheme`: `:http` or `:https`.
- `#request_method`: `:get`, `:post`...
- `#host`: e.g. `'www.example.org'`.
- `#ip`:  e.g. `'192.168.1.1'`.
- `#port`: e.g. `80` or `443`.
- `#script_name`: e.g. `'index.rb'`.
- `#path_info`: e.g. `'/foor/bar'`.
- `#query_string`: e.g. `'foo=bar&bar=foo'`
- `#request_body`: e.g. `'{ id: 1 }'`
- `#request_headers`: e.g. `{ 'Accept-Charset' => 'utf8' }`
- `#env`: Rack's env hash.
- `#request`: Rack::Request instance.

Your operations must return another (or the same) instance of the struct, which
will be consumed by the next operation downstream.

The struct contains methods to add the response data to it:

- `#set_status(code)`: makes it accessible in the `#status` attribute.
- `#set_response_body(body)`: makes it accessible in the `#response_body`
  attribute.
- `#set_response_headers(headers)`: makes them accessible in
  the `#response_headers` attribute. Besides, there are also
  `#add_response_header(key, value)` and `#delete_response_header(key)`
  methods.

The response in the last struct returned in the pipe will be what is sent to
client.

Every attribute and method is [fully
documented](https://www.rubydoc.info/github/waiting-for-dev/web_pipe/master/WebPipe/Conn)
in the code documentation.

Here we have a contrived web application which returns as response body
the request body it has received:

```ruby
# config.ru
require 'web_pipe'

class DummyApp
  include WebPipe
  
  plug :build_response
  
  private
  
  def build_response(conn)
    conn.
      set_status(200).
      add_response_header('Content-Type', 'text/html').
      set_response_body(
        "<p>#{conn.request_body}</p>"
      )
  end
end

run DummyApp.new
```

As you can see, by default, the available features are very minimal to read
from a request and to write a response. However, you can pick from several
(extensions)[extensions.md] which will make your life much easier.

Immutability is a core design principle in `web_pipe`. All methods in
`WebPipe::Conn`, which are used to add data to it (both in core behavior and
extensions), return a fresh new instance. It also makes possible chaining
methods in a very readable way.

If you're using ruby 2.7 or greater, you can pattern match on a `WebPipe::Conn`
struct, as in:

```ruby
# GET http://example.org
conn in { request_method:, host: }
request_method
# :get
host
# 'example.org'
```

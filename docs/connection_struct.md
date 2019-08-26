# Connection struct

The first operation you plug receives an instance of `WebPipe::Conn` which has
been automatically created.

This is just a struct data type which contains all the information from the
current web request. In this regard, you can think of it as a structured rack's
env hash.

The request related attributes of the struct are:

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
will be consumed by the next operation downstream. The struct also contains
methods to add to it the response data:

- `#set_status(code)`: makes it accessible in `#status` attribute.
- `#set_response_body(body)`: makes it accessible in `#response_body`
  attribute.
- `#set_response_headers(headers)`: makes them accessible in
  `#response_headers` attribute. Besides, there are also
  `#add_response_header(key, value)` and `#delete_response_header(key)`
  methods.

The response in the struct returned by the last executed operation will be what
is sent to the client.

Every attribute and method is [fully
documented](https://www.rubydoc.info/github/waiting-for-dev/web_pipe/master/WebPipe/Conn)
in the code docs.

Here we have a contrived web application which just returns as response body
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

As you see, available features are the very minimal to read from a request and
write to a response. However, you can pick from several extensions which will
make your life much easier.

Immutability is a core design principle in `web_pipe`. All methods
in `WebPipe::Conn`, both in core behaviour and extensions, which
are used to add data to it return a fresh new instance. It also
makes possible to chain methods in a very readable way.

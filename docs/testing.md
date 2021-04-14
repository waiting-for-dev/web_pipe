# Testing

## Testing the rack application

A `WebPipe` instance is a just a rack application, so you can test it as such:

```ruby
require 'web_pipe'
require 'rack/mock'
require 'rspec'

class MyApp
  include WebPipe

  plug :response

  private

  def response(conn)
    conn
      .set_response_body('Hello!')
      .set_status(200)
  end
end

RSpec.describe MyApp do
  it 'responds with 200 status code' do
    env = Rack::MockRequest.env_for

    status, _headers, _body = described_class.new.call(env)

    expect(status).to be(200)
  end
end
```

## Testing individual operations

Each operation in a pipe is an isolated function that takes a connection struct
as argument. You can leverage [the inspection of
operations](docs/plugging_operations/inspecting_operations.md) to unit test them.

There's also a `WebPipe::TestSupport` module that you can include to get a
helper method `#build_conn` to easily create a connection struct.

```ruby
RSpec.describe MyApp do
  include WebPipe::TestSupport

  describe '#response' do
    it 'responds with 200 status code' do
      conn = build_conn
      operation = described_class.new.operations[:response]

      new_conn = operation.call(conn)

      expect(new_conn.status).to be(200)
    end
  end
end
```

Check the API documentation for the options you can provide to
[`#build_conn`](https://www.rubydoc.info/github/waiting-for-dev/web_pipe/master/WebPipe/TestSupport#build_conn).

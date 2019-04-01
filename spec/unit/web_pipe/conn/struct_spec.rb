require 'web_pipe/conn/struct'
require 'support/env'
require 'rack'

RSpec.describe WebPipe::Conn::Struct do
  describe '#fetch_redundants' do
    let(:env) do
      DEFAULT_ENV.merge(
        Rack::HTTPS => 'on',
        Rack::HTTP_HOST => 'www.host.org',
        Rack::SERVER_PORT => '80',
        Rack::PATH_INFO => '/home',
        Rack::QUERY_STRING => 'foo=bar'
      )
    end
    let(:conn) { WebPipe::Conn::Builder.call(env) }
    let(:new_conn) { conn.fetch_redundants }

    it 'fills base_url with request base url' do
      expect(new_conn.base_url).to eq('https://www.host.org:80')
    end

    it 'fills path with request path' do
      expect(new_conn.path).to eq('/home')
    end

    it 'fills full_path with request full path' do
      expect(new_conn.full_path).to eq('/home?foo=bar')
    end

    it 'fills url with request url' do
      expect(new_conn.url).to eq('https://www.host.org:80/home?foo=bar')
    end

    it 'fills params with request params' do
      expect(new_conn.params).to eq({ 'foo' => 'bar' })
    end
  end

  describe '#fetch_request_body' do
    let(:env) do
      DEFAULT_ENV.merge(
        Rack::RACK_INPUT => '{ "foo": "bar" }'
      )
    end
    let(:conn) { WebPipe::Conn::Builder.call(env) }

    it 'fills body with request body' do
      new_conn =  conn.fetch_request_body

      expect(new_conn.request_body).to eq('{ "foo": "bar" }')
    end

    it 'allows callable parser to be injected' do
      parser = -> (body) { JSON.parse(body) }

      new_conn =  conn.fetch_request_body(parser)

      expect(new_conn.request_body).to eq({ "foo" => "bar" })
    end
  end

  describe '#fetch_request_headers' do
    it 'fills headers with env HTTP_ pairs as hash' do
      env = DEFAULT_ENV.merge('HTTP_F' => 'BAR')
      conn = WebPipe::Conn::Builder.call(env)

      new_conn = conn.fetch_request_headers

      expect(new_conn.request_headers).to eq({ 'F' => 'BAR' })
    end

    it 'normalize keys to Pascal case and switching _ by -' do
      env = DEFAULT_ENV.merge('HTTP_FOO_BAR' => 'foobar')
      conn = WebPipe::Conn::Builder.call(env)

      new_conn = conn.fetch_request_headers

      expect(new_conn.request_headers).to eq({ 'Foo-Bar' => 'foobar' })
    end

    it 'includes content type CGI var' do
      env = DEFAULT_ENV.merge('CONTENT_TYPE' => 'text/html')
      conn = WebPipe::Conn::Builder.call(env)

      new_conn = conn.fetch_request_headers

      expect(new_conn.request_headers['Content-Type']).to eq('text/html')
    end

    it 'includes content length CGI var' do
      env = DEFAULT_ENV.merge('CONTENT_LENGTH' => '10')
      conn = WebPipe::Conn::Builder.call(env)

      new_conn = conn.fetch_request_headers

      expect(new_conn.request_headers['Content-Length']).to eq('10')
    end

    it 'defaults to empty hash' do
      conn = WebPipe::Conn::Builder.call(DEFAULT_ENV)

      new_conn = conn.fetch_request_headers

      expect(new_conn.request_headers).to eq({})
    end
  end

  describe 'set_status' do
    it 'sets status' do
      conn = WebPipe::Conn::Builder.call(DEFAULT_ENV)

      new_conn = conn.set_status(404)

      expect(new_conn.status).to be(404)
    end
  end

  describe 'set_response_body' do
    context 'when value is a string' do
      it 'sets response body as one item array of given value' do
        conn = WebPipe::Conn::Builder.call(DEFAULT_ENV).yield_self do |c|
          c.new(response_body: ['foo'])
        end

        new_conn = conn.set_response_body('bar')

        expect(new_conn.response_body).to eq(['bar'])
      end
    end

    context 'when value is an array' do
      it 'it substitutes whole response_body' do
        conn = WebPipe::Conn::Builder.call(DEFAULT_ENV).yield_self do |c|
          c.new(response_body: ['foo'])
        end

        new_conn = conn.set_response_body(['bar', 'var'])

        expect(new_conn.response_body).to eq(['bar', 'var'])
      end
    end
  end

  describe 'add_response_header' do
    it 'adds given pair to response headers' do
      conn = WebPipe::Conn::Builder.call(DEFAULT_ENV).yield_self do |c|
        c.new(response_headers: { 'Foo' => 'Bar' })
      end

      new_conn = conn.add_response_header('Bar', 'Foo')

      expect(new_conn.response_headers).to eq({ 'Foo' => 'Bar', 'Bar' => 'Foo' })
    end

    it 'normalize keys to Pascal case and switching _ by -' do
      conn = WebPipe::Conn::Builder.call(DEFAULT_ENV)

      new_conn = conn.add_response_header('foo_foo', 'Bar')

      expect(new_conn.response_headers).to eq({ 'Foo-Foo' => 'Bar' })
    end
  end

  describe 'delete_response_header' do
    it 'deletes response header with given key' do
      conn = WebPipe::Conn::Builder.call(DEFAULT_ENV).yield_self do |c|
        c.new(response_headers: { 'Foo' => 'Bar', 'Zoo' => 'Zar' })
      end

      new_conn = conn.delete_response_header('Zoo')

      expect(new_conn.response_headers).to eq({ 'Foo' => 'Bar' })
    end

    it 'accepts non normalized keys' do
      conn = WebPipe::Conn::Builder.call(DEFAULT_ENV).yield_self do |c|
        c.new(response_headers: { 'Foo-Foo' => 'Bar' })
      end

      new_conn = conn.delete_response_header('foo_foo')

      expect(new_conn.response_headers).to eq({})
    end
  end

  describe '#fetch_cookies' do
    it 'fills cookies with request session' do
      env = DEFAULT_ENV.merge(Rack::RACK_SESSION => { "foo" => "bar" })
      conn = WebPipe::Conn::Builder.call(env)

      new_conn = conn.fetch_cookies

      expect(new_conn.cookies).to eq({ "foo" => "bar" })
    end
  end

  describe '#rack_response' do
    let(:env) { DEFAULT_ENV.merge(Rack::RACK_SESSION => { "foo" => "bar" }) }
    let(:conn) do
      WebPipe::Conn::Builder.call(env).yield_self do |conn|
        conn.
          add_response_header('Content-Type', 'plain/text').
          set_status(404).
          set_response_body('Not found')
      end
    end
    let(:rack_response) { conn.rack_response }

    it 'builds status from status attribute' do
      expect(conn.rack_response[0]).to be(404)
    end

    it 'builds response headers from response_headers attribute' do
      expect(conn.rack_response[1]).to eq({ 'Content-Type' => 'plain/text' })
    end

    it 'builds response body from response_body attribute' do
      expect(conn.rack_response[2]).to eq(['Not found'])
    end
  end
end
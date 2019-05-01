require 'web_pipe/conn/struct'
require 'web_pipe/conn/errors'
require 'support/env'
require 'rack'

RSpec.describe WebPipe::Conn::Struct do
  describe '#base_url' do
    it 'returns request base url' do
      env = DEFAULT_ENV.merge(
        Rack::HTTPS => 'on',
        Rack::HTTP_HOST => 'www.host.org',
        Rack::SERVER_PORT => '8000',
      )

      conn = WebPipe::Conn::Builder.call(env)

      expect(conn.base_url).to eq('https://www.host.org:8000')
    end
  end

  describe '#path' do
    it 'returns request path' do
      env = DEFAULT_ENV.merge(
        Rack::SCRIPT_NAME => 'index.rb',
        Rack::PATH_INFO => '/foo'
      )

      conn = WebPipe::Conn::Builder.call(env)

      expect(conn.path).to eq('index.rb/foo')
    end
  end

  describe '#full_path' do
    it 'returns request fullpath' do
      env = DEFAULT_ENV.merge(
        Rack::PATH_INFO => '/foo',
        Rack::QUERY_STRING => 'foo=bar',
      )

      conn = WebPipe::Conn::Builder.call(env)

      expect(conn.full_path).to eq('/foo?foo=bar')
    end
  end

  describe '#url' do
    it 'returns request url' do
      env = DEFAULT_ENV.merge(
        Rack::HTTPS => 'on',
        Rack::HTTP_HOST => 'www.host.org',
        Rack::PATH_INFO => '/home',
        Rack::SERVER_PORT => '8000',
        Rack::QUERY_STRING => 'foo=bar'
      )

      conn = WebPipe::Conn::Builder.call(env)

      expect(conn.url).to eq('https://www.host.org:8000/home?foo=bar')
    end
  end

  describe '#params' do
    it 'returns request params' do
      env = DEFAULT_ENV.merge(
        Rack::QUERY_STRING => 'foo=bar'
      )

      conn = WebPipe::Conn::Builder.call(env)

      expect(conn.params).to eq({ 'foo' => 'bar'})
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

    context 'when value responds to :each' do
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
        c.new(response_headers: { 'Foo' => 'Foo' })
      end

      new_conn = conn.add_response_header('foo_foo', 'Bar')

      expect(new_conn.response_headers).to eq({ 'Foo' => 'Foo', 'Foo-Foo' => 'Bar' })
    end
  end

  describe 'delete_response_header' do
    it 'deletes response header with given key' do
      conn = WebPipe::Conn::Builder.call(DEFAULT_ENV).yield_self do |c|
        c.new(response_headers: { 'Foo' => 'Bar', 'Zoo-Zoo' => 'Zar' })
      end

      new_conn = conn.delete_response_header('zoo_zoo')

      expect(new_conn.response_headers).to eq({ 'Foo' => 'Bar' })
    end
  end

  describe 'fetch' do
    it 'returns item in bag with given key' do
      conn = WebPipe::Conn::Builder.call(DEFAULT_ENV).yield_self do |c|
        c.new(bag: { foo: :bar })
      end

      expect(conn.fetch(:foo)).to be(:bar)
    end

    it 'raises KeyNotFoundInBagError when key does not exist' do
      conn = WebPipe::Conn::Builder.call(DEFAULT_ENV)
      
      expect {
        conn.fetch(:foo)
      }.to raise_error(WebPipe::Conn::KeyNotFoundInBagError)
    end
  end

  describe 'put' do
    it 'sets key/value pair in bag' do
      conn = WebPipe::Conn::Builder.call(DEFAULT_ENV)

      new_conn = conn.put(:foo, :bar)

      expect(new_conn.bag[:foo]).to be(:bar)
    end
  end

  describe '#rack_response' do
    let(:env) { DEFAULT_ENV.merge(Rack::RACK_SESSION => { "foo" => "bar" }) }
    let(:conn) do
      WebPipe::Conn::Builder.call(env).yield_self do |conn|
        conn.
          add_response_header('Content-Type', 'text/plain').
          set_status(404).
          set_response_body('Not found')
      end
    end
    let(:rack_response) { conn.rack_response }

    it 'builds status from status attribute' do
      expect(conn.rack_response[0]).to be(404)
    end

    it 'builds response headers from response_headers attribute' do
      expect(conn.rack_response[1]).to eq({ 'Content-Type' => 'text/plain' })
    end

    it 'builds response body from response_body attribute' do
      expect(conn.rack_response[2]).to eq(['Not found'])
    end
  end
end
require 'web_pipe/conn'
require 'web_pipe/conn_support/errors'
require 'support/env'
require 'rack'

RSpec.describe WebPipe::Conn do
  def build(env)
    WebPipe::ConnSupport::Builder.call(env)
  end

  describe '#base_url' do
    it 'returns request base url' do
      env = default_env.merge(
        Rack::HTTPS => 'on',
        Rack::HTTP_HOST => 'www.host.org',
        Rack::SERVER_PORT => '8000',
      )

      conn = build(env)

      expect(conn.base_url).to eq('https://www.host.org:8000')
    end
  end

  describe '#path' do
    it 'returns request path' do
      env = default_env.merge(
        Rack::SCRIPT_NAME => 'index.rb',
        Rack::PATH_INFO => '/foo'
      )

      conn = build(env)

      expect(conn.path).to eq('index.rb/foo')
    end
  end

  describe '#full_path' do
    it 'returns request fullpath' do
      env = default_env.merge(
        Rack::PATH_INFO => '/foo',
        Rack::QUERY_STRING => 'foo=bar',
      )

      conn = build(env)

      expect(conn.full_path).to eq('/foo?foo=bar')
    end
  end

  describe '#url' do
    it 'returns request url' do
      env = default_env.merge(
        Rack::HTTPS => 'on',
        Rack::HTTP_HOST => 'www.host.org',
        Rack::PATH_INFO => '/home',
        Rack::SERVER_PORT => '8000',
        Rack::QUERY_STRING => 'foo=bar'
      )

      conn = build(env)

      expect(conn.url).to eq('https://www.host.org:8000/home?foo=bar')
    end
  end

  describe '#router_params' do
    it "returns env's router.params key" do
      env = default_env.merge(
        'router.params' => { 'id' => '1' }
      )

      conn = build(env)

      expect(conn.router_params).to eq({ 'id' => '1' })
    end

    it "returns empty hash when key is not present" do
      conn = build(default_env)

      expect(conn.router_params).to eq({})
    end
  end

  describe '#params' do
    it 'includes request params' do
      env = default_env.merge(
        Rack::QUERY_STRING => 'foo=bar'
      )

      conn = build(env)

      expect(conn.params).to eq({ 'foo' => 'bar'})
    end

    it "includes router params" do
      env = default_env.merge(
        Rack::QUERY_STRING => 'foo=bar',
        'router.params' => { 'id' => '1' }
      )

      conn = build(env)

      expect(conn.params).to eq({ 'foo' => 'bar', 'id' => '1'})
    end
  end

  describe 'set_status' do
    it 'sets status' do
      conn = build(default_env)

      new_conn = conn.set_status(404)

      expect(new_conn.status).to be(404)
    end
  end

  describe 'set_response_body' do
    context 'when value is a string' do
      it 'sets response body as one item array of given value' do
        conn = build(default_env).new(response_body: ['foo'])

        new_conn = conn.set_response_body('bar')

        expect(new_conn.response_body).to eq(['bar'])
      end
    end

    context 'when value responds to :each' do
      it 'it substitutes whole response_body' do
        conn = build(default_env).new(response_body: ['foo'])

        new_conn = conn.set_response_body(['bar', 'var'])

        expect(new_conn.response_body).to eq(['bar', 'var'])
      end
    end
  end

  describe 'add_response_header' do
    it 'adds given pair to response headers' do
      conn = build(default_env).new(
        response_headers: { 'Foo' => 'Foo' }
      )

      new_conn = conn.add_response_header('foo_foo', 'Bar')

      expect(
        new_conn.response_headers
      ).to eq({ 'Foo' => 'Foo', 'Foo-Foo' => 'Bar' })
    end
  end

  describe 'delete_response_header' do
    it 'deletes response header with given key' do
      conn = build(default_env).new(
        response_headers: { 'Foo' => 'Bar', 'Zoo-Zoo' => 'Zar' }
      )

      new_conn = conn.delete_response_header('zoo_zoo')

      expect(new_conn.response_headers).to eq({ 'Foo' => 'Bar' })
    end
  end

  describe 'fetch' do
    it 'returns item in bag with given key' do
      conn = build(default_env).new(bag: { foo: :bar })

      expect(conn.fetch(:foo)).to be(:bar)
    end

    it 'raises KeyNotFoundInBagError when key does not exist' do
      conn = build(default_env)
      
      expect {
        conn.fetch(:foo)
      }.to raise_error(WebPipe::ConnSupport::KeyNotFoundInBagError)
    end

    it 'returns default when it is given and key does not exist' do
      conn = build(default_env)

      expect(conn.fetch(:foo, :bar)).to be(:bar)
    end
  end

  describe 'put' do
    it 'sets key/value pair in bag' do
      conn = build(default_env)

      new_conn = conn.put(:foo, :bar)

      expect(new_conn.bag[:foo]).to be(:bar)
    end
  end

  describe '#rack_response' do
    let(:env) { default_env.merge(Rack::RACK_SESSION => { "foo" => "bar" }) }
    let(:conn) do
      conn = build(env)
      conn.
        add_response_header('Content-Type', 'text/plain').
        set_status(404).
        set_response_body('Not found')
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
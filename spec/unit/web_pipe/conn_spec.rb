require 'web_pipe/conn'
require 'web_pipe/conn_support/errors'
require 'support/conn'
require 'rack'

RSpec.describe WebPipe::Conn do
  def build(env)
    build_conn(env)
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

  describe 'set_response_headers' do
    it 'sets response headers' do
      conn = build(default_env)

      new_conn = conn.set_response_headers({ 'foo' => 'bar' })

      expect(new_conn.response_headers).to eq({ 'Foo' => 'bar' })
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

  describe 'add' do
    it 'adds key/value pair to bag' do
      conn = build(default_env)

      new_conn = conn.add(:foo, :bar)

      expect(new_conn.bag[:foo]).to be(:bar)
    end
  end

  describe 'fetch_config' do
    it 'returns item in config with given key' do
      conn = build(default_env).new(config: { foo: :bar })

      expect(conn.fetch_config(:foo)).to be(:bar)
    end

    it 'raises KeyNotFoundInConfigError when key does not exist' do
      conn = build(default_env)
      
      expect {
        conn.fetch_config(:foo)
      }.to raise_error(WebPipe::ConnSupport::KeyNotFoundInConfigError)
    end

    it 'returns default when it is given and key does not exist' do
      conn = build(default_env)

      expect(conn.fetch_config(:foo, :bar)).to be(:bar)
    end
  end

  describe 'add' do
    it 'adds key/value pair to config' do
      conn = build(default_env)

      new_conn = conn.add_config(:foo, :bar)

      expect(new_conn.config[:foo]).to be(:bar)
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

  describe '#halted?' do
    it 'returns true when class is a Halted instance' do
      conn = build_conn(default_env).halt

      expect(conn.halted?).to be(true)
    end

    it 'returns false when class is a Ongoing instance' do
      conn = build_conn(default_env)

      expect(conn.halted?).to be(false)
    end
  end
end
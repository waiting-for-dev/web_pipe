require 'spec_helper'
require 'web_pipe'
require 'support/env'

RSpec.describe WebPipe::Conn do
  before { WebPipe.load_extensions(:url) }
  
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
  end
end
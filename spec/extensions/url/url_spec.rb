require 'spec_helper'
require 'web_pipe'
require 'support/conn'

RSpec.describe WebPipe::Conn do
  before { WebPipe.load_extensions(:url) }
  
  def build(env)
    build_conn(env)
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
end
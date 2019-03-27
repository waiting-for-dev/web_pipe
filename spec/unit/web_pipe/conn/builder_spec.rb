require 'spec_helper'
require 'web_pipe/conn/types'
require 'web_pipe/conn/builder'
require 'web_pipe/conn'
require 'support/env'

RSpec.describe WebPipe::Conn::Builder do
  def remove_key(hash, key)
    hash.reject { |k, _v| k == key }
  end

  describe ".call" do
    it 'creates a CleanConn' do
      conn = described_class.call(DEFAULT_ENV)

      expect(conn).to be_an_instance_of(WebPipe::CleanConn)
    end

    context 'request' do
      context 'rack_env' do
        it 'fills in with rack env' do
          env = DEFAULT_ENV

          conn = described_class.call(env)

          expect(conn.request.rack_env).to be(DEFAULT_ENV)
        end
      end

      context 'rack_request' do
        it 'fills in with rack request' do
          env = DEFAULT_ENV

          conn = described_class.call(env)

          expect(conn.request.rack_request).to be_an_instance_of(Rack::Request)
        end
      end

      context 'params' do
        it 'fills in with unfetched of params type' do
          env = DEFAULT_ENV

          conn = described_class.call(env)

          expect(conn.request.params).to eq(WebPipe::Conn::Types::Request::Unfetched.new(type: :params))
        end
      end

      context 'headers' do
        it 'fills in with env HTTP_ pairs as hash' do
          env = DEFAULT_ENV.merge('HTTP_F' => 'BAR')

          conn = described_class.call(env)

          expect(conn.request.headers).to eq({ 'F' => 'BAR' })
        end

        it 'substitute _ by - and do Pascal case on - for keys' do
          env = DEFAULT_ENV.merge('HTTP_CONTENT_TYPE' => 'text/html')

          conn = described_class.call(env)

          expect(conn.request.headers).to eq({ 'Content-Type' => 'text/html' })
        end

        it 'defaults to empty hash' do
          conn = described_class.call(DEFAULT_ENV)

          expect(conn.request.headers).to eq({})
        end
      end

      context 'req_method' do
        it 'fills in with downcased request method as symbol' do
          env = DEFAULT_ENV.merge(Rack::REQUEST_METHOD => 'POST')

          conn = described_class.call(env)

          expect(conn.request.req_method).to eq(:post)
        end
      end

      context 'script_name' do
        it 'fills in with request script name' do
          env = DEFAULT_ENV.merge(Rack::SCRIPT_NAME => 'index.rb')

          conn = described_class.call(env)

          expect(conn.request.script_name).to eq('index.rb')
        end

        it 'defaults to empty string' do
          env = remove_key(DEFAULT_ENV, Rack::SCRIPT_NAME)

          conn = described_class.call(env)

          expect(conn.request.script_name).to eq('')
        end
      end

      context 'path_info' do
        it 'fills in with request path info' do
          env = DEFAULT_ENV.merge(Rack::PATH_INFO => '/foo/bar')

          conn = described_class.call(env)

          expect(conn.request.path_info).to eq('/foo/bar')
        end

        it 'defaults to empty string' do
          env = remove_key(DEFAULT_ENV, Rack::PATH_INFO)

          conn = described_class.call(env)

          expect(conn.request.path_info).to eq('')
        end
      end

      context 'query_string' do
        it 'fills in with request query string' do
          env = DEFAULT_ENV.merge(Rack::QUERY_STRING => 'foo=bar')

          conn = described_class.call(env)

          expect(conn.request.query_string).to eq('foo=bar')
        end
      end

      context 'host' do
        it 'fills in with request host' do
          env = DEFAULT_ENV.merge(Rack::HTTP_HOST => 'www.host.org')

          conn = described_class.call(env)

          expect(conn.request.host).to eq('www.host.org')
        end
      end

      context 'port' do
        it 'fills in with request port' do
          env = DEFAULT_ENV.merge(Rack::SERVER_PORT => '443')

          conn = described_class.call(env)

          expect(conn.request.port).to eq(443)
        end
      end

      context 'base_url' do
        it 'fills in with request base url' do
          env = DEFAULT_ENV.merge(
            Rack::HTTPS => 'on',
            Rack::SERVER_NAME => 'www.example.org',
            Rack::SERVER_PORT => '88')

          conn = described_class.call(env)

          expect(conn.request.base_url).to eq('https://www.example.org:88')
        end
      end

      context 'scheme' do
        it 'fills with request scheme as symbol' do
          env = DEFAULT_ENV.merge(Rack::HTTPS => 'on')

          conn = described_class.call(env)

          expect(conn.request.scheme).to eq(:https)
        end
      end
    end
  end
end
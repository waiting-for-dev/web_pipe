require 'spec_helper'
require 'web_pipe/conn/types'
require 'web_pipe/conn/builder'
require 'web_pipe/conn'
require 'support/env'

RSpec.describe WebPipe::Conn::Builder do
  def unfetched(type)
    WebPipe::Conn::Types::Request::Unfetched.new(type: type)
  end

  def unset(type)
    WebPipe::Conn::Types::Response::Unset.new(type: type)
  end

  describe ".call" do
    it 'creates a CleanConn' do
      conn = described_class.call(DEFAULT_ENV)

      expect(conn).to be_an_instance_of(WebPipe::CleanConn)
    end

    context 'env' do
      it 'fills in with rack env' do
        env = DEFAULT_ENV

        conn = described_class.call(env)

        expect(conn.env).to be(DEFAULT_ENV)
      end
    end

    context 'request' do
      it 'fills in with rack request' do
        env = DEFAULT_ENV

        conn = described_class.call(env)

        expect(conn.request).to be_an_instance_of(Rack::Request)
      end
    end

    context 'scheme' do
      it 'fills with request scheme as symbol' do
        env = DEFAULT_ENV.merge(Rack::HTTPS => 'on')

        conn = described_class.call(env)

        expect(conn.scheme).to eq(:https)
      end
    end

    context 'request_method' do
      it 'fills in with downcased request method as symbol' do
        env = DEFAULT_ENV.merge(Rack::REQUEST_METHOD => 'POST')

        conn = described_class.call(env)

        expect(conn.request_method).to eq(:post)
      end
    end

    context 'host' do
      it 'fills in with request host' do
        env = DEFAULT_ENV.merge(Rack::HTTP_HOST => 'www.host.org')

        conn = described_class.call(env)

        expect(conn.host).to eq('www.host.org')
      end
    end

    context 'ip' do
      it 'fills in with request ip' do
        env = DEFAULT_ENV.merge('REMOTE_ADDR' => '0.0.0.0')

        conn = described_class.call(env)

        expect(conn.ip).to eq('0.0.0.0')
      end

      it 'defaults to nil' do
        env = DEFAULT_ENV

        conn = described_class.call(env)

        expect(conn.ip).to be_nil
      end
    end

    context 'port' do
      it 'fills in with request port' do
        env = DEFAULT_ENV.merge(Rack::SERVER_PORT => '443')

        conn = described_class.call(env)

        expect(conn.port).to eq(443)
      end
    end

    context 'script_name' do
      it 'fills in with request script name' do
        env = DEFAULT_ENV.merge(Rack::SCRIPT_NAME => 'index.rb')

        conn = described_class.call(env)

        expect(conn.script_name).to eq('index.rb')
      end
    end

    context 'path_info' do
      it 'fills in with request path info' do
        env = DEFAULT_ENV.merge(Rack::PATH_INFO => '/foo/bar')

        conn = described_class.call(env)

        expect(conn.path_info).to eq('/foo/bar')
      end
    end

    context 'query_string' do
      it 'fills in with request query string' do
        env = DEFAULT_ENV.merge(Rack::QUERY_STRING => 'foo=bar')

        conn = described_class.call(env)

        expect(conn.query_string).to eq('foo=bar')
      end
    end

    context 'request_headers' do
      it 'fills in with unfetched of headers type' do
        env = DEFAULT_ENV

        conn = described_class.call(env)

        expect(conn.request_headers).to eq(unfetched(:headers))
      end
    end

    context 'base_url' do
      it 'fills in with unfetched of base_url type' do
        env = DEFAULT_ENV

        conn = described_class.call(env)

        expect(conn.base_url).to eq(unfetched(:base_url))
      end
    end

    context 'path' do
      it 'fills in with unfetched of path type' do
        env = DEFAULT_ENV

        conn = described_class.call(env)

        expect(conn.path).to eq(unfetched(:path))
      end
    end

    context 'full_path' do
      it 'fills in with unfetched of full_path type' do
        env = DEFAULT_ENV

        conn = described_class.call(env)

        expect(conn.full_path).to eq(unfetched(:full_path))
      end
    end

    context 'url' do
      it 'fills in with unfetched of url type' do
        env = DEFAULT_ENV

        conn = described_class.call(env)

        expect(conn.url).to eq(unfetched(:url))
      end
    end

    context 'params' do
      it 'fills in with unfetched of params type' do
        env = DEFAULT_ENV

        conn = described_class.call(env)

        expect(conn.params).to eq(unfetched(:params))
      end
    end

    context 'request_body' do
      it 'fills in with unfetched of body type' do
        env = DEFAULT_ENV

        conn = described_class.call(env)

        expect(conn.request_body).to eq(unfetched(:body))
      end
    end

    context 'status' do
      it 'fills in with unset of status type' do
        env = DEFAULT_ENV

        conn = described_class.call(env)

        expect(conn.status).to eq(unset(:status))
      end
    end

    context 'response_body' do
      it 'let it to initialize with its default' do
        env = DEFAULT_ENV

        conn = described_class.call(env)

        expect(conn.response_body).to eq([''])
      end
    end

    context 'response_headers' do
      it 'let it to initialize with its default' do
        env = DEFAULT_ENV

        conn = described_class.call(env)

        expect(conn.response_headers).to eq({})
      end
    end
  end

  context 'cookies' do
    it 'fills in with unfetched of cookies type' do
      env = DEFAULT_ENV

      conn = described_class.call(env)

      expect(conn.cookies).to eq(unfetched(:cookies))
    end
  end
end
require 'spec_helper'
require 'web_pipe/conn_support/builder'
require 'web_pipe/conn'
require 'support/env'

RSpec.describe WebPipe::ConnSupport::Builder do
  describe ".call" do
    it 'creates a Conn::Clean' do
      conn = described_class.call(DEFAULT_ENV)

      expect(conn).to be_an_instance_of(WebPipe::Conn::Clean)
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

    context 'request_body' do
      it 'fills in with request body' do
        request_body = StringIO.new('foo=bar')
        env = DEFAULT_ENV.merge(
          Rack::RACK_INPUT => request_body
        )

        conn = described_class.call(env)

        expect(conn.request_body).to eq(request_body)
      end
    end

    describe '#request_headers' do
      it 'fills in with extracted headers from env' do
        env = DEFAULT_ENV.merge('HTTP_FOO_BAR' => 'BAR')

        conn = described_class.call(env)

        expect(conn.request_headers).to eq({ 'Foo-Bar' => 'BAR' })
      end
    end

    context 'status' do
      it 'let it to initialize with its default' do
        env = DEFAULT_ENV

        conn = described_class.call(env)

        expect(conn.status).to be(200)
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

  context 'bag' do
    it 'let it to initialize with its default' do
      env = DEFAULT_ENV

      conn = described_class.call(env)

      expect(conn.bag).to eq({})
    end
  end
end
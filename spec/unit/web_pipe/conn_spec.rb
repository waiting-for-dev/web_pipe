require 'web_pipe/conn'
require 'support/env'
require 'rack'

RSpec.describe WebPipe::Conn do
  context 'request' do
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
      let(:new_conn) { conn.request.fetch_redundants }

      it 'fills base_url with request base url' do
        expect(new_conn.request.base_url).to eq('https://www.host.org:80')
      end

      it 'fills path with request path' do
        expect(new_conn.request.path).to eq('/home')
      end

      it 'fills full_path with request full path' do
        expect(new_conn.request.full_path).to eq('/home?foo=bar')
      end

      it 'fills url with request url' do
        expect(new_conn.request.url).to eq('https://www.host.org:80/home?foo=bar')
      end

      it 'fills params with request params' do
        expect(new_conn.request.params).to eq({ 'foo' => 'bar' })
      end
    end

    describe '#fetch_body' do
      let(:env) do
        DEFAULT_ENV.merge(
          Rack::RACK_INPUT => '{ "foo": "bar" }'
        )
      end
      let(:conn) { WebPipe::Conn::Builder.call(env) }

      it 'fills body with request body' do
        new_conn =  conn.request.fetch_body

        expect(new_conn.request.body).to eq('{ "foo": "bar" }')
      end

      it 'allows callable parser to be injected' do
        parser = -> (body) { JSON.parse(body) }

        new_conn =  conn.request.fetch_body(parser)

        expect(new_conn.request.body).to eq({ "foo" => "bar" })
      end
    end

    describe '#fetch_headers' do
      it 'fills headers with env HTTP_ pairs as hash' do
        env = DEFAULT_ENV.merge('HTTP_F' => 'BAR')
        conn = WebPipe::Conn::Builder.call(env)

        new_conn = conn.request.fetch_headers

        expect(new_conn.request.headers).to eq({ 'F' => 'BAR' })
      end

      it 'normalize keys to Pascal case and switching _ by -' do
        env = DEFAULT_ENV.merge('HTTP_FOO_BAR' => 'foobar')
        conn = WebPipe::Conn::Builder.call(env)

        new_conn = conn.request.fetch_headers

        expect(new_conn.request.headers).to eq({ 'Foo-Bar' => 'foobar' })
      end

      it 'includes content type CGI var' do
        env = DEFAULT_ENV.merge('CONTENT_TYPE' => 'text/html')
        conn = WebPipe::Conn::Builder.call(env)

        new_conn = conn.request.fetch_headers

        expect(new_conn.request.headers['Content-Type']).to eq('text/html')
      end

      it 'includes content length CGI var' do
        env = DEFAULT_ENV.merge('CONTENT_LENGTH' => '10')
        conn = WebPipe::Conn::Builder.call(env)

        new_conn = conn.request.fetch_headers

        expect(new_conn.request.headers['Content-Length']).to eq('10')
      end

      it 'defaults to empty hash' do
        conn = WebPipe::Conn::Builder.call(DEFAULT_ENV)

        new_conn = conn.request.fetch_headers

        expect(new_conn.request.headers).to eq({})
      end
    end

    describe '#fetch_cookies' do
      it 'fills cookies with request session' do
        env = DEFAULT_ENV.merge(Rack::RACK_SESSION => { "foo" => "bar" })
        conn = WebPipe::Conn::Builder.call(env)

        new_conn = conn.request.fetch_cookies

        expect(new_conn.request.cookies).to eq({ "foo" => "bar" })
      end
    end
  end

  context 'response' do
    describe 'set_status' do
      it 'sets status' do
        conn = WebPipe::Conn::Builder.call(DEFAULT_ENV)

        new_conn = conn.set_status(404)

        expect(new_conn.response.status).to be(404)
      end
    end
  end
end
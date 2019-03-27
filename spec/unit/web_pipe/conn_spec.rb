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
        new_conn=  conn.request.fetch_body

        expect(new_conn.request.body).to eq('{ "foo": "bar" }')
      end

      it 'allows callable parser to be injected' do
        parser = -> (body) { JSON.parse(body) }

        new_conn=  conn.request.fetch_body(parser)

        expect(new_conn.request.body).to eq({ "foo" => "bar" })
      end
    end
  end
end
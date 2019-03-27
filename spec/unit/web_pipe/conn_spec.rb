require 'web_pipe/conn'
require 'support/env'
require 'rack'

RSpec.describe WebPipe::Conn do
  context 'request' do
    describe '#fetch_params' do
      it 'fills params with request params' do
        env = DEFAULT_ENV.merge(Rack::QUERY_STRING => 'foo=bar')
        conn = WebPipe::Conn::Builder.call(env)

        new_conn = conn.request.fetch_params

        expect(new_conn.request.params).to eq({ 'foo' => 'bar' })
      end
    end
  end
end
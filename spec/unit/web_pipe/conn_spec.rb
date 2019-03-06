require 'spec_helper'
require 'web_pipe/conn'
require 'support/env'

RSpec.describe WebPipe::Conn do
  subject(:conn) { described_class.build(env) }

  describe '#request' do
    describe '#params' do
      context 'when there is query string' do
        let(:env) { DEFAULT_ENV.merge("QUERY_STRING" => "foo=bar") }

        it 'returns hash with query parameters' do
          expect(conn.request.params).to eq({ "foo" => "bar" })
        end
      end

      context 'when there is no query string' do
        let(:env) { DEFAULT_ENV.merge("QUERY_STRING" => "") }

        it 'returns the empty hash' do
          expect(conn.request.params).to eq({})
        end
      end
    end
  end
end
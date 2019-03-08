require 'spec_helper'
require 'web_pipe/conn/builder'
require 'web_pipe/conn'
require 'support/env'

RSpec.describe WebPipe::Conn::Builder do
  describe ".call" do
    it 'creates a CleanConn' do
      conn = described_class.call(DEFAULT_ENV)

      expect(conn).to be_an_instance_of(WebPipe::CleanConn)
    end

    context 'request' do
      context 'params' do
        context 'when there is query string' do
          it 'fills with query parameters' do
            env = DEFAULT_ENV.merge("QUERY_STRING" => "foo=bar")

            conn = described_class.call(env)

            expect(conn.request.params).to eq({ "foo" => "bar" })
          end
        end

        context 'when there is no query string' do
          it 'fills with empty hash' do
            env = DEFAULT_ENV.merge("QUERY_STRING" => "")

            conn = described_class.call(env)

            expect(conn.request.params).to eq({})
          end
        end
      end

      context 'headers' do
        context 'when there is some request headers' do
          it 'fills them as a hash' do
            env = DEFAULT_ENV.merge("HTTP_FOO" => "BAR")

            conn = described_class.call(env)

            expect(conn.request.headers).to eq({ "FOO" => "BAR" })
          end
        end

        context 'when there is no request headers' do
          it 'fills with empty hash' do
            conn = described_class.call(DEFAULT_ENV)

            expect(conn.request.headers).to eq({})
          end
        end
      end
    end
  end
end
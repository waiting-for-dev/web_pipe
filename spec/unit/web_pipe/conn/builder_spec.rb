require 'spec_helper'
require 'web_pipe/conn/builder'
require 'web_pipe/conn'
require 'support/env'

RSpec.describe WebPipe::Conn::Builder do
  describe ".call" do
    subject(:conn) { described_class.call(env) }

    context 'creation' do
      let(:env) { DEFAULT_ENV }

      it 'creates a CleanConn' do
        expect(conn).to be_an_instance_of(WebPipe::CleanConn)
      end
    end

    context 'request' do
      context 'params' do
        context 'when there is query string' do
          let(:env) { DEFAULT_ENV.merge("QUERY_STRING" => "foo=bar") }

          it 'fills with query parameters' do
            expect(conn.request.params).to eq({ "foo" => "bar" })
          end
        end

        context 'when there is no query string' do
          let(:env) { DEFAULT_ENV.merge("QUERY_STRING" => "") }

          it 'fills with empty hash' do
            expect(conn.request.params).to eq({})
          end
        end
      end

      context 'headers' do
        context 'when there is some request headers' do
          let(:env) { DEFAULT_ENV.merge("HTTP_FOO" => "BAR") }

          it 'fills them as a hash' do
            expect(conn.request.headers).to eq({ "FOO" => "BAR" })
          end
        end

        context 'when there is no request headers' do
          let(:env) { DEFAULT_ENV }

          it 'fills with empty hash' do
            expect(conn.request.headers).to eq({})
          end
        end
      end
    end
  end
end
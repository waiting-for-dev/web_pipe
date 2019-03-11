require 'spec_helper'
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
            env = DEFAULT_ENV.merge('HTTP_F' => 'BAR')

            conn = described_class.call(env)

            expect(conn.request.headers).to eq({ 'F' => 'BAR' })
          end

          it 'substitute _ by - and do Pascal case on - for keys' do
            env = DEFAULT_ENV.merge('HTTP_CONTENT_TYPE' => 'text/html')

            conn = described_class.call(env)

            expect(conn.request.headers).to eq({ 'Content-Type' => 'text/html' })
          end
        end

        context 'when there is no request headers' do
          it 'fills with empty hash' do
            conn = described_class.call(DEFAULT_ENV)

            expect(conn.request.headers).to eq({})
          end
        end
      end

      context 'req_method' do
        it 'fills with request method' do
          env = DEFAULT_ENV.merge('REQUEST_METHOD' => 'POST')

          conn = described_class.call(env)

          expect(conn.request.req_method).to eq(:post)
        end
      end

      context 'script_name' do
        it 'fills with script name' do
          env = DEFAULT_ENV.merge('SCRIPT_NAME' => 'index.rb')

          conn = described_class.call(env)

          expect(conn.request.script_name).to eq('index.rb')
        end

        it 'defaults to empty string when not present' do
          env = remove_key(DEFAULT_ENV, 'SCRIPT_NAME')

          conn = described_class.call(env)

          expect(conn.request.script_name).to eq('')
        end
      end

      context 'path_info' do
        it 'fills with path info' do
          env = DEFAULT_ENV.merge('PATH_INFO' => '/foo/bar')

          conn = described_class.call(env)

          expect(conn.request.path_info).to eq('/foo/bar')
        end

        it 'defaults to empty string when not present' do
          env = remove_key(DEFAULT_ENV, 'PATH_INFO')

          conn = described_class.call(env)

          expect(conn.request.path_info).to eq('')
        end
      end

      context 'query_string' do
        it 'fills with query string' do
          env = DEFAULT_ENV.merge('QUERY_STRING' => 'foo=bar')

          conn = described_class.call(env)

          expect(conn.request.query_string).to eq('foo=bar')
        end
      end

      context 'server_name' do
        it 'fills with server name' do
          env = DEFAULT_ENV.merge('SERVER_NAME' => 'www.example.org')

          conn = described_class.call(env)

          expect(conn.request.server_name).to eq('www.example.org')
        end
      end

      context 'server_port' do
        it 'fills with server port as integer' do
          env = DEFAULT_ENV.merge('SERVER_PORT' => '443')

          conn = described_class.call(env)

          expect(conn.request.server_port).to eq(443)
        end
      end
    end
  end
end
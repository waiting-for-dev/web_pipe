require 'spec_helper'
require 'support/conn'

RSpec.describe WebPipe::Conn do
  before { WebPipe.load_extensions(:cookies) }

  let(:conn) { build_conn(default_env) }

  describe '#request_cookies' do
    it 'returns request cookies' do
      env = default_env.merge('HTTP_COOKIE' => 'foo=bar')

      conn = build_conn(env)

      expect(conn.request_cookies).to eq({ 'foo' => 'bar' })
    end
  end

  describe '#set_cookie' do
    it 'sets given name/value pair to the Set-Cookie header' do
      conn = build_conn(default_env)

      new_conn = conn.set_cookie('foo', 'bar')

      expect(new_conn.response_headers['Set-Cookie']).to eq('foo=bar')
    end

    it 'adds given options to the cookie value' do
      conn = build_conn(default_env)

      new_conn = conn.set_cookie('foo', 'bar', path: '/')

      expect(new_conn.response_headers['Set-Cookie']).to eq('foo=bar; path=/')
    end
  end

  describe '#delete_cookie' do
    it 'marks given key/value pair cookie for deletion' do
      conn = build_conn(default_env)

      new_conn = conn.delete_cookie('foo')

      expect(new_conn.response_headers['Set-Cookie']).to eq(
        'foo=; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 -0000'
      )
    end

    it 'adds given options to the cookie value' do
      conn = build_conn(default_env)

      new_conn = conn.delete_cookie('foo', domain: '/')

      expect(new_conn.response_headers['Set-Cookie']).to eq(
        'foo=; domain=/; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 -0000'
      )
    end
  end
end

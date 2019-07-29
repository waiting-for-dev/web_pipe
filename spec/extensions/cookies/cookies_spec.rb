require 'spec_helper'
require 'support/env'
require 'web_pipe/conn_support/builder'

RSpec.describe WebPipe::Conn do
  before { WebPipe.load_extensions(:cookies) }

  let(:conn) { WebPipe::ConnSupport::Builder.(DEFAULT_ENV) }

  describe '#set_cookie' do
    it 'sets given name/value pair to the Set-Cookie header' do
      new_conn = conn.set_cookie('foo', 'bar')

      expect(new_conn.response_headers['Set-Cookie']).to eq('foo=bar')
    end

    it 'adds given options to the cookie value' do
      new_conn = conn.set_cookie('foo', 'bar', path: '/')

      expect(new_conn.response_headers['Set-Cookie']).to eq('foo=bar; path=/')
    end
  end

  describe '#delete_cookie' do
    it 'marks given key/value pair cookie for deletion' do
      new_conn = conn.delete_cookie('foo')

      expect(new_conn.response_headers['Set-Cookie']).to eq(
        'foo=; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 -0000'
      )
    end

    it 'adds given options to the cookie value' do
      new_conn = conn.delete_cookie('foo', domain: '/')

      expect(new_conn.response_headers['Set-Cookie']).to eq(
        'foo=; domain=/; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 -0000'
      )
    end
  end
end
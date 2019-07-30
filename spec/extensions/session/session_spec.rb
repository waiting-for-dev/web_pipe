require 'spec_helper'
require 'support/env'
require 'web_pipe'
require 'web_pipe/conn_support/builder'

RSpec.describe WebPipe::Conn do
  before { WebPipe.load_extensions(:session) }

  describe '#session' do
    context 'when rack session key is found in env' do
      it 'returns its value' do
        session = {}
        env = default_env.merge('rack.session' => session)
        conn = WebPipe::ConnSupport::Builder.call(env)

        expect(conn.session).to be(session)
      end
    end

    context 'when rack session key is not found in env' do
      it 'raises a MissingMiddlewareError' do
        conn = WebPipe::ConnSupport::Builder.call(default_env)

        expect { conn.session }.to raise_error(WebPipe::ConnSupport::MissingMiddlewareError)
      end
    end
  end

  describe '#fetch_session' do
    it 'returns given item from session' do
      env = default_env.merge('rack.session' => { 'foo' => 'bar' })
      conn = WebPipe::ConnSupport::Builder.call(env)

      expect(conn.fetch_session('foo')).to eq('bar')
    end

    it 'returns default when not found' do
      env = default_env.merge('rack.session' => {})
      conn = WebPipe::ConnSupport::Builder.call(env)

      expect(conn.fetch_session('foo', 'bar')).to eq('bar')
    end

    it 'returns what block returns when key is not found and no default is given' do
      env = default_env.merge('rack.session' => {})
      conn = WebPipe::ConnSupport::Builder.call(env)

      expect(conn.fetch_session('foo') { 'bar' }).to eq('bar')
    end
  end

  describe '#put_session' do
    it 'adds given name/value pair to session' do
      env = default_env.merge('rack.session' => {})
      conn = WebPipe::ConnSupport::Builder.call(env)

      new_conn = conn.put_session('foo', 'bar')

      expect(new_conn.session['foo']).to eq('bar')
    end
  end

  describe '#delete_session' do
    it 'deletes given name from the session' do
      env = default_env.merge('rack.session' => { 'foo' => 'bar', 'bar' => 'foo' })
      conn = WebPipe::ConnSupport::Builder.call(env)

      new_conn = conn.delete_session('foo')

      expect(new_conn.session).to eq('bar' => 'foo')
    end
  end

  describe '#clear_session' do
    it 'resets session' do
      env = default_env.merge('rack.session' => { 'foo' => 'bar' })
      conn = WebPipe::ConnSupport::Builder.call(env)

      new_conn = conn.clear_session

      expect(new_conn.session).to eq({})
    end
  end
end
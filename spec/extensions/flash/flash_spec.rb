require 'spec_helper'
require 'support/env'
require 'web_pipe/conn'
require 'web_pipe/conn_support/builder'
require 'web_pipe/conn_support/errors'
require 'rack-flash'

RSpec.describe WebPipe::Conn do
  before do
    WebPipe.load_extensions(:flash)
  end

  let(:flash) { Rack::Flash::FlashHash.new({}) }

  describe '#flash' do
    context "when rack-flash key is found in env" do
      it 'returns its value' do
        env = default_env.merge('x-rack.flash' => flash)
        conn = WebPipe::ConnSupport::Builder.call(env)

        expect(conn.flash).to be(flash)
      end
    end

    context "when rack-flash key is not found in env" do
      it 'raises a MissingMiddlewareError' do
        conn = WebPipe::ConnSupport::Builder.call(default_env)

        expect { conn.flash }.to raise_error(WebPipe::ConnSupport::MissingMiddlewareError)
      end
    end
  end

  describe '#put_flash' do
    it 'sets given key to given value in flash' do
      env = default_env.merge('x-rack.flash' => flash)
      conn = WebPipe::ConnSupport::Builder.call(env)

      conn = conn.put_flash(:error, 'error')

      expect(flash[:error]).to eq('error')
    end
  end

  describe '#put_flash_now' do
    it 'sets given key to given value in flash cache' do
      env = default_env.merge('x-rack.flash' => flash)
      conn = WebPipe::ConnSupport::Builder.call(env)

      conn = conn.put_flash_now(:error, 'error')

      expect(flash.send(:cache)[:error]).to eq('error')
    end
  end
end
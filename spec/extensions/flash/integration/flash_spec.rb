require 'spec_helper'
require 'support/env'
require 'web_pipe'
require 'rack/session/cookie'
require 'rack-flash'

RSpec.describe 'Using flash' do
  before { WebPipe.load_extensions(:flash) }
  
  let(:pipe) do
    Class.new do
      include WebPipe

      use :session, ::Rack::Session::Cookie, secret: 'secret'
      use :flash, ::Rack::Flash

      plug :put_in_flash
      plug :build_response

      private

      def put_in_flash(conn)
        conn.
          put_flash(:error, 'Error').
          put_flash_now(:now, 'now')
      end

      def build_response(conn)
        conn.set_response_body(
          "#{conn.flash[:error]} #{conn.flash[:now]}"
        )
      end
    end.new
  end

  it 'can put and read from flash' do
    expect(pipe.call(default_env).last[0]).to eq('Error now')
  end
end
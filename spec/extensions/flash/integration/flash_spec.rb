# frozen_string_literal: true

require "spec_helper"
require "support/conn"
require "rack/session/cookie"
require "rack-flash"

RSpec.describe "Using flash" do
  before { WebPipe.load_extensions(:flash) }

  let(:pipe) do
    Class.new do
      include WebPipe

      use :session, Rack::Session::Cookie, secret: "secret"
      use :flash, Rack::Flash

      plug :add_to_flash
      plug :build_response

      private

      def add_to_flash(conn)
        conn
          .add_flash(:error, "Error")
          .add_flash_now(:now, "now")
      end

      def build_response(conn)
        conn.set_response_body(
          "#{conn.flash[:error]} #{conn.flash[:now]}"
        )
      end
    end.new
  end

  it "can adadd and read from flash" do
    expect(pipe.(default_env).last[0]).to eq("Error now")
  end
end

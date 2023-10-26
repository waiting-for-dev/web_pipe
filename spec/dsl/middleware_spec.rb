# frozen_string_literal: true

require "spec_helper"
require "support/conn"
require "support/middlewares"

RSpec.describe "Using rack middlewares" do
  let(:pipe) do
    Class.new do
      include WebPipe

      use :first_name, FirstNameMiddleware
      use :last_name, LastNameMiddleware, name: "Doe"

      plug :hello

      private

      def hello(conn)
        first_name = conn.env["first_name"]
        last_name = conn.env["last_name"]
        conn
          .set_response_body(
            "Hello #{first_name} #{last_name}"
          )
      end
    end.new
  end

  it "can use middlewares" do
    expect(pipe.(default_env).last[0]).to eq("Hello Joe Doe")
  end
end

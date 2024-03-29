# frozen_string_literal: true

require "spec_helper"
require "support/conn"
require "support/middlewares"

RSpec.describe "Composition" do
  let(:pipe) do
    Class.new do
      # rubocop:disable Lint/ConstantDefinitionInBlock
      class App
        include WebPipe

        use :first_name, FirstNameMiddleware

        plug :gretting, ->(conn) { conn.add(:greeting, "Hello") }
      end
      # rubocop:enable Lint/ConstantDefinitionInBlock

      include WebPipe

      compose :app, App.new

      use :last_name, LastNameMiddleware, name: "Doe"
      plug :perform_greeting

      private

      def perform_greeting(conn)
        first_name = conn.env["first_name"]
        last_name = conn.env["last_name"]
        greeting = conn.fetch(:greeting)
        conn
          .set_response_body(
            "#{greeting} #{first_name} #{last_name}"
          )
      end
    end.new
  end

  it "using a WebPipe composes its middlewares and plugs" do
    expect(pipe.(default_env).last[0]).to eq("Hello Joe Doe")
  end
end

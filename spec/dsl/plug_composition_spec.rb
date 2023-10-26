# frozen_string_literal: true

require "spec_helper"
require "support/conn"

RSpec.describe "Plug composition" do
  let(:pipe) do
    Class.new do
      # rubocop:disable Lint/ConstantDefinitionInBlock
      class One
        include WebPipe

        plug :one

        private

        def one(conn)
          conn.set_response_body("One")
        end
      end
      # rubocop:enable Lint/ConstantDefinitionInBlock

      include WebPipe

      plug :one, One.new
      plug :two

      private

      def two(conn)
        conn.set_response_body(
          "#{conn.response_body[0]}Two"
        )
      end
    end.new
  end

  it "plugging a WebPipe composes its plug operations" do
    expect(pipe.(default_env).last).to eq(["OneTwo"])
  end
end

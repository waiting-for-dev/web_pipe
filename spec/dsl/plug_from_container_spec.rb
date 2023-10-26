# frozen_string_literal: true

require "spec_helper"
require "support/conn"

RSpec.describe "Resolving plugs from a container" do
  let(:pipe) do
    Class.new do
      # rubocop:disable Lint/ConstantDefinitionInBlock
      Container = Hash[
        "plug.hello" => ->(conn) { conn.set_response_body("Hello, world!") }
      ]
      # rubocop:enable Lint/ConstantDefinitionInBlock

      include WebPipe.(container: Container)

      plug :hello, "plug.hello"
    end.new
  end

  it "can resolve operation from a container" do
    expect(pipe.(default_env).last).to eq(["Hello, world!"])
  end
end

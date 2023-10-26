# frozen_string_literal: true

require "spec_helper"
require "support/conn"

RSpec.describe "Inspecting operations" do
  let(:pipe_class) do
    Class.new do
      include WebPipe

      plug :one, ->(conn) { conn.set_response_body("One") }
    end
  end

  it "can inspect resolved operations" do
    pipe = pipe_class.new
    conn = build_conn(default_env)

    expect(
      pipe.operations[:one].(conn).response_body
    ).to eq(["One"])
  end

  it "can inspect injected operations" do
    two = ->(conn) { conn.set_response_body("Two") }
    pipe = pipe_class.new(plugs: { one: two })
    conn = build_conn(default_env)

    expect(
      pipe.operations[:one].(conn).response_body
    ).to eq(["Two"])
  end
end

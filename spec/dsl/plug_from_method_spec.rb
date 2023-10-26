# frozen_string_literal: true

require "spec_helper"
require "support/conn"

RSpec.describe "Resolving plugs from a method" do
  let(:pipe) do
    Class.new do
      include WebPipe

      plug :hello

      def hello(conn)
        conn.set_response_body("Hello, world!")
      end
    end.new
  end

  it "can resolve operation from an internal method" do
    expect(pipe.(default_env).last).to eq(["Hello, world!"])
  end
end

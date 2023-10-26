# frozen_string_literal: true

require "spec_helper"
require "support/conn"

RSpec.describe "Overriding instance methods" do
  it "can define custom initialize and call super" do
    pipe = Class.new do
      include WebPipe

      attr_reader :greeting

      def initialize(greeting:, **kwargs)
        @greeting = greeting
        super(**kwargs)
      end

      plug :name

      plug :render

      private

      def name
        raise NotImplementedError
      end

      def render(conn)
        conn.set_response_body(greeting + conn.fetch(:name))
      end
    end.new(greeting: "Hello, ", plugs: { name: ->(conn) { conn.add(:name, "Alice") } })

    expect(pipe.(default_env).last[0]).to eq("Hello, Alice")
  end

  it "can define custom pipe methods and call super" do
    pipe = Class.new do
      include WebPipe

      plug :render

      def call(env)
        env["body"] = "Hello, world!"
        super(env)
      end

      private

      def render(conn)
        conn.set_response_body(conn.env["body"])
      end
    end.new

    expect(pipe.(default_env).last[0]).to eq("Hello, world!")
  end
end

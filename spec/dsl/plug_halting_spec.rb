# frozen_string_literal: true

require "spec_helper"
require "support/conn"

RSpec.describe "Plug halting" do
  let(:pipe) do
    Class.new do
      include WebPipe

      plug :halt
      plug :ongoing

      private

      def halt(conn)
        conn.set_response_body("Halted").halt
      end

      def ongoing(conn)
        conn.set_response_body("Ongoing")
      end
    end.new
  end

  it "halting plug stops the pipe" do
    expect(pipe.(default_env).last).to eq(["Halted"])
  end
end

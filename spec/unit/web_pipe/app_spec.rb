# frozen_string_literal: true

require "spec_helper"
require "support/conn"

RSpec.describe WebPipe::App do
  describe "#call" do
    it "chains operations on Conn" do
      op1 = ->(conn) { conn.set_status(200) }
      op2 = ->(conn) { conn.set_response_body("foo") }

      app = described_class.new([op1, op2])

      expect(app.(default_env)).to eq([200, {}, ["foo"]])
    end

    it "stops chain propagation once a conn is halted" do
      op1 = ->(conn) { conn.set_status(200) }
      op2 = ->(conn) { conn.set_response_body("foo") }
      op3 = ->(conn) { conn.halt }
      op4 = ->(conn) { conn.set_response_body("bar") }

      app = described_class.new([op1, op2, op3, op4])

      expect(app.(default_env)).to eq([200, {}, ["foo"]])
    end

    it "raises InvalidOperationReturn when one operation does not return a Conn" do
      op = ->(_conn) { :foo }

      app = described_class.new([op])

      expect do
        app.(default_env)
      end.to raise_error(
        WebPipe::ConnSupport::Composition::InvalidOperationResult
      )
    end
  end
end

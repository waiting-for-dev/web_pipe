# frozen_string_literal: true

require "spec_helper"
require "web_pipe"
require "support/conn"

RSpec.describe WebPipe::Conn do
  before { WebPipe.load_extensions(:not_found) }

  describe "#not_found" do
    it "sets 404 status code" do
      conn = build_conn

      expect(conn.not_found.status).to be(404)
    end

    it "halts it" do
      conn = build_conn

      expect(conn.not_found.halted?).to be(true)
    end

    context "when no response body is configured" do
      it 'sets "Not found" as response body' do
        conn = build_conn

        expect(conn.not_found.response_body).to eq(["Not found"])
      end
    end

    context "when a step to build the response body is configured" do
      it "uses it" do
        conn = build_conn.add_config(:not_found_body_step,
                                     ->(c) { c.set_response_body("Nothing here") })

        expect(conn.not_found.response_body).to eq(["Nothing here"])
      end
    end
  end
end

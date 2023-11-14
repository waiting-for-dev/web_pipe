# frozen_string_literal: true

require "spec_helper"

RSpec.describe WebPipe::TestSupport do
  let(:klass) do
    Class.new { include WebPipe::TestSupport }.new
  end

  describe "#build_conn" do
    it "returns a WebPipe::Conn::Ongoing instance" do
      expect(
        klass.build_conn.instance_of?(WebPipe::Conn::Ongoing)
      ).to be(true)
    end

    it "can shortcut through uri" do
      conn = klass.build_conn("http://dummy.org?foo=bar")

      expect(conn.host).to eq("dummy.org")
      expect(conn.query_string).to eq("foo=bar")
    end

    it "can override attributes" do
      conn = klass.build_conn(attributes: { host: "foo.bar" })

      expect(conn.host).to eq("foo.bar")
    end

    it "gives preference to the attributes over the uri" do
      conn = klass.build_conn("http://joe.doe", attributes: { host: "foo.bar" })

      expect(conn.host).to eq("foo.bar")
    end

    it "can forward env options" do
      conn = klass.build_conn(env_opts: { method: "PUT" })

      expect(conn.request_method).to be(:put)
    end
  end
end

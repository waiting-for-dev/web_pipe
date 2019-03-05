require 'spec_helper'
require 'web_pipe/conn'
require 'support/env'

RSpec.describe WebPipe::Conn do
  subject(:conn) { described_class.build(env) }

  describe "#request" do
    describe "#params" do
      let(:env) { DEFAULT_ENV.merge("QUERY_STRING" => "foo=bar") }

      it "returns hash with query parameters" do
        expect(conn.request.params).to eq({ "foo" => "bar" })
      end
    end
  end
end
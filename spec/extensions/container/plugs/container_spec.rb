require 'spec_helper'
require 'support/conn'
require 'web_pipe/extensions/container/plugs/container'
require 'web_pipe/conn_support/builder'

RSpec.describe WebPipe::Plugs::Container do
  describe '.[]' do
    it "creates an operation which sets argument into bag's ':container' key" do
      conn = build_conn(default_env)
      container = {}.freeze
      plug = described_class[container]

      new_conn = plug.(conn)

      expect(new_conn.fetch(:container)).to be(container)
    end
  end
end
require 'spec_helper'
require 'support/conn'

RSpec.describe WebPipe::Conn do
  before do
    WebPipe.load_extensions(:container)
  end

  describe '#container' do
    it "returns bag's container key" do
      conn = build_conn(default_env)
      container = {}.freeze

      new_conn = conn.add(:container, container)

      expect(new_conn.container).to be(container)
    end
  end
end
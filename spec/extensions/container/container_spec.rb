require 'spec_helper'
require 'support/env'

RSpec.describe WebPipe::Conn do
  before do
    WebPipe.load_extensions(:container)
  end

  describe '#container' do
    it "returns bag's container key" do
      conn = WebPipe::ConnSupport::Builder.call(DEFAULT_ENV)
      container = {}.freeze

      new_conn = conn.put(:container, container)

      expect(new_conn.container).to be(container)
    end
  end
end
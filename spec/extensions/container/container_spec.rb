require 'spec_helper'
require 'support/env'
require 'web_pipe/conn'

RSpec.describe WebPipe::Conn do
  before do
    WebPipe.load_extensions(:container)
  end

  let(:container) { {'foo' => 'bar'}.freeze }

  before { WebPipe::Conn.config.container = container }

  describe '#config' do
    it "has a 'container' setting" do
      expect(WebPipe::Conn.config.container).to be(container)
    end
  end

  it "has a 'container' reader" do
    expect(WebPipe::Conn.container).to be(container)
  end
end
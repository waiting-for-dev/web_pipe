require 'spec_helper'
require 'support/conn'
require 'web_pipe/plugs/content_type'
require 'web_pipe/conn_support/builder'

RSpec.describe WebPipe::Plugs::ContentType do
  describe '.[]' do
    it "creates an operation which adds given argument as Content-Type header" do
      conn = build_conn(default_env)
      plug = described_class['text/html']

      new_conn = plug.(conn)

      expect(new_conn.response_headers['Content-Type']).to eq('text/html')
    end
  end
end
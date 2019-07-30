require 'spec_helper'
require 'support/env'
require 'web_pipe/plugs/content_type'
require 'web_pipe/conn_support/builder'

RSpec.describe WebPipe::Plugs::ContentType do
  describe '.[]' do
    it "creates an operation which adds given argument as Content-Type header" do
      conn = WebPipe::ConnSupport::Builder.call(default_env)
      plug = described_class['text/html']

      new_conn = plug.(conn)

      expect(new_conn.response_headers['Content-Type']).to eq('text/html')
    end
  end
end
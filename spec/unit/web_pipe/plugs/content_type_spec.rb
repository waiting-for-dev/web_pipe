# frozen_string_literal: true

require 'spec_helper'
require 'support/conn'
require 'web_pipe/plugs/content_type'

RSpec.describe WebPipe::Plugs::ContentType do
  describe '.call' do
    it 'creates an operation which adds given argument as Content-Type header' do
      conn = build_conn(default_env)
      operation = described_class.call('text/html')

      new_conn = operation.call(conn)

      expect(new_conn.response_headers['Content-Type']).to eq('text/html')
    end
  end
end

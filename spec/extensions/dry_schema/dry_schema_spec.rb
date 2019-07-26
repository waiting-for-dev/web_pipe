require 'spec_helper'
require 'support/env'
require 'web_pipe'
require 'web_pipe/conn_support/builder'

RSpec.describe WebPipe::Conn do
  before { WebPipe.load_extensions(:dry_schema) }

  describe '#sanitized_params' do
    it "returns bag's sanitized key" do
      conn = WebPipe::ConnSupport::Builder.(DEFAULT_ENV)
      sanitized_params = {}.freeze

      new_conn = conn.put(:sanitized_params, sanitized_params)

      expect(new_conn.sanitized_params).to be(sanitized_params)
    end
  end
end
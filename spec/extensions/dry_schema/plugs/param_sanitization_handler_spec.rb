require 'spec_helper'
require 'support/conn'
require 'web_pipe/conn_support/builder'
require 'web_pipe/extensions/dry_schema/plugs/param_sanitization_handler'

RSpec.describe WebPipe::Plugs::ParamSanitizationHandler do
  describe '.[]' do
    it 'operation sets :param_sanitization_handler bag key' do
      conn = WebPipe::ConnSupport::Builder.(default_env)
      handler = ->(conn, _result) { conn }
      operation = described_class[handler]

      new_conn = operation.(conn)

      expect(new_conn.fetch(:param_sanitization_handler)).to be(handler)
    end
  end
end
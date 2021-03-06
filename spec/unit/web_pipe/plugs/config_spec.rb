# frozen_string_literal: true

require 'spec_helper'
require 'support/conn'
require 'web_pipe/plugs/config'

RSpec.describe WebPipe::Plugs::Config do
  describe '.call' do
    it 'creates an operation which adds given pairs to config' do
      conn = build_conn(default_env).add_config(:zoo, :zoo)
      operation = described_class.call(
        foo: :bar,
        rar: :ror
      )

      new_conn = operation.call(conn)

      expect(new_conn.config).to eq(zoo: :zoo, foo: :bar, rar: :ror)
    end
  end
end

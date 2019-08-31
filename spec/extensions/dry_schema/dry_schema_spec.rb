# frozen_string_literal: true

require 'spec_helper'
require 'support/conn'
require 'web_pipe'

RSpec.describe WebPipe::Conn do
  before { WebPipe.load_extensions(:dry_schema) }

  describe '#sanitized_params' do
    it "returns config's sanitized key" do
      conn = build_conn(default_env)
      sanitized_params = {}.freeze

      new_conn = conn.add_config(:sanitized_params, sanitized_params)

      expect(new_conn.fetch_config(:sanitized_params)).to be(sanitized_params)
    end
  end
end

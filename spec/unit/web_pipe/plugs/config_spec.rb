# frozen_string_literal: true

require "spec_helper"
require "support/conn"

RSpec.describe WebPipe::Plugs::Config do
  describe ".call" do
    it "creates an operation which adds given pairs to config" do
      conn = build_conn(default_env).add_config(:zoo, :zoo)
      operation = described_class.(foo: :bar,
                                   rar: :ror)

      new_conn = operation.(conn)

      expect(new_conn.config).to eq(zoo: :zoo, foo: :bar, rar: :ror)
    end
  end
end

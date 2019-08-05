require 'spec_helper'
require 'support/conn'
require 'web_pipe/plugs/config'

RSpec.describe WebPipe::Plugs::Config do
  describe '.[]' do
    it "creates an operation which adds given pairs to config" do
      conn = build_conn(default_env).add_config(:zoo, :zoo)
      plug = described_class[
        foo: :bar,
        rar: :ror
      ]

      new_conn = plug.(conn)

      expect(new_conn.config).to eq(zoo: :zoo, foo: :bar, rar: :ror)
    end
  end
end
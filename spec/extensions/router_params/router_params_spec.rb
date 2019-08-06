require 'spec_helper'
require 'support/conn'

RSpec.describe WebPipe::Params::Transf do
  before { WebPipe.load_extensions(:router_params) }

  describe '.router_params' do
    it "merges 'router.params' key from env into given hash" do
      env = default_env.merge('router.params' => { foo: :bar })
      conn = build_conn(env)

      expect(
        described_class[:router_params].with(conn).(bar: :foo)
      ).to eq(foo: :bar, bar: :foo)
    end

    it "assumes empty hash when 'router.params' is not present" do
      conn = build_conn(default_env)

      expect(
        described_class[:router_params].with(conn).(bar: :foo)
      ).to eq(bar: :foo)
    end
  end
end

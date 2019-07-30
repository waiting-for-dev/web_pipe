require 'spec_helper'
require 'support/env'
require 'web_pipe/conn_support/builder'
require 'web_pipe'
require 'web_pipe/extensions/dry_view/plugs/view_context'

RSpec.describe WebPipe::Plugs::ViewContext do
  before do
    WebPipe.load_extensions(:dry_view)
  end

  describe '.[]' do
    it "creates an operation which calls given proc with conn and sets result into bag's view_context key" do
      conn = WebPipe::ConnSupport::Builder.
               call(default_env).
               put(:foo, 'bar')
      view_context_proc = ->(conn) { { foo: conn.fetch(:foo) } }
      plug = described_class[view_context_proc]

      new_conn = plug.(conn)

      expect(new_conn.fetch(WebPipe::Conn::VIEW_CONTEXT_KEY)).to eq({ foo: 'bar' })
    end
  end
end
require 'spec_helper'
require 'support/conn'
require 'web_pipe/conn_support/composition'
require 'web_pipe/conn_support/builder'

RSpec.describe WebPipe::ConnSupport::Composition do
  let(:conn) { build_conn(default_env) }
  
  describe '#call' do
    it 'chains operations on Conn' do
      op_1 = ->(conn) { conn.set_status(200) }
      op_2 = ->(conn) { conn.set_response_body('foo') }

      app = described_class.new([op_1, op_2])

      expect(app.call(conn)).to eq(
        op_2.(op_1.(conn))
      )
    end

    it 'stops chain propagation once a conn is tainted' do
      op_1 = ->(conn) { conn.set_status(200) }
      op_2 = ->(conn) { conn.set_response_body('foo') }
      op_3 = ->(conn) { conn.taint }
      op_4 = ->(conn) { conn.set_response_body('bar') }

      app = described_class.new([op_1, op_2, op_3, op_4])

      expect(app.call(conn)).to eq(
        op_3.(op_2.(op_1.(conn)))
      )
    end

    it 'raises InvalidOperationReturn when one operation does not return a Conn' do
      op = ->(_conn) { :foo }

      app = described_class.new([op])

      expect {
        app.call(conn)
      }.to raise_error(WebPipe::ConnSupport::Composition::InvalidOperationResult)
    end
  end
end
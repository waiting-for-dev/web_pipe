require 'spec_helper'
require 'support/env'
require 'web_pipe/pipe/app'

RSpec.describe WebPipe::Pipe::App do
  describe '#call' do
    it 'chains operations on Conn' do
      op_1 = ->(conn) { conn.set_status(200) }
      op_2 = ->(conn) { conn.set_response_body('foo') }

      app = described_class.new([op_1, op_2])

      expect(app.call(DEFAULT_ENV)).to eq([200, {}, ['foo']])
    end

    it 'stops chain propagation once a conn is tainted' do
      op_1 = ->(conn) { conn.set_status(200) }
      op_2 = ->(conn) { conn.set_response_body('foo') }
      op_3 = ->(conn) { conn.taint }
      op_4 = ->(conn) { conn.set_response_body('bar') }

      app = described_class.new([op_1, op_2, op_3, op_4])

      expect(app.call(DEFAULT_ENV)).to eq([200, {}, ['foo']])
    end
  end
end
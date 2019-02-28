require 'spec_helper'

RSpec.describe "Composing" do
  let(:pipe_1) do
    Class.new do
      include Dry::Request.Pipe()

      plug :one, with: -> (conn) { conn.put_response_body('One') }
    end
  end

  let(:pipe_2) do
    Class.new do
      include Dry::Request.Pipe()

      plug :two, with: -> (conn) { conn.put_response_body(conn.resp_body + 'Two') }
    end
  end

  it 'pipes can be composed' do
    expect((pipe_1 >> pipe_2).new.call({}).last).to eq(['OneTwo'])
  end
end
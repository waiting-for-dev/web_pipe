require 'spec_helper'

RSpec.describe "Chaining" do
  let(:pipe) do
    Class.new do
      include Dry::Request.Pipe()

      plug :one, with: -> (conn) { conn.put_response_body('One') }
      plug :two, with: -> (conn) { conn.put_response_body(conn.resp_body + 'Two') }
    end.new
  end

  it 'chains successful plugs' do
    expect(pipe.call({}).last).to eq(['OneTwo'])
  end
end
require 'spec_helper'
require 'support/env'

RSpec.describe "Chaining" do
  let(:pipe) do
    Class.new do
      include WebPipe

      plug :one, with: -> (conn) { conn.put_response_body('One') }
      plug :two, with: -> (conn) { conn.put_response_body(conn.resp_body + 'Two') }
    end.new
  end

  it 'chains successful plugs' do
    expect(pipe.call(DEFAULT_ENV).last).to eq(['OneTwo'])
  end
end
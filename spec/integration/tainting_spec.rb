require 'spec_helper'

RSpec.describe "Tainting" do
  let(:pipe) do
    Class.new do
      include Dry::Request.Pipe()

      plug :dirty, with: -> (conn) { conn.put_response_body('Dirty') && conn.taint }
      plug :clean, with: -> (conn) { conn.put_response_body('Clean') }
    end.new
  end

  it 'dirty step stops the pipe' do
    expect(pipe.call({}).last).to eq(['Dirty'])
  end
end
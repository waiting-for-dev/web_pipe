require 'spec_helper'

RSpec.describe "Resolving from a container" do
  before do
    Container = Hash.new
    Container["plug.hello"] = -> (conn) { conn.put_response_body('Hello, world!') }
    Container
  end

  let(:pipe) do
    Class.new do
      include Dry::Request.Pipe(container: Container)

      plug :hello, with: "plug.hello"
    end.new
  end

  it 'can resolve operation from a container' do
    expect(pipe.call({}).last).to eq(['Hello, world!'])
  end
end
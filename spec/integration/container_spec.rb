require 'spec_helper'

RSpec.describe "Resolving from a container" do
  let(:pipe) do
    Class.new do
      self::Container = Hash["plug.hello" => -> (conn) { conn.put_response_body('Hello, world!') }]

      include Dry::Request.Pipe(container: self::Container)

      plug :hello, with: "plug.hello"
    end.new
  end

  it 'can resolve operation from a container' do
    expect(pipe.call({}).last).to eq(['Hello, world!'])
  end
end
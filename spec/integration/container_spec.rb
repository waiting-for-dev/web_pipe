require 'spec_helper'
require 'support/env'

RSpec.describe "Resolving from a container" do
  let(:pipe) do
    Class.new do
      Container = Hash[
        'plug.hello' => -> (conn) { conn.set_response_body('Hello, world!') }
      ]

      include WebPipe.(container: Container)

      plug :hello, 'plug.hello'
    end.new
  end

  it 'can resolve operation from a container' do
    expect(pipe.call(DEFAULT_ENV).last).to eq(['Hello, world!'])
  end
end
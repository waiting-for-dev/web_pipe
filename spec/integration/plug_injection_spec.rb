require 'spec_helper'
require 'support/conn'

RSpec.describe "Plug injection" do
  let(:pipe) do
    Class.new do
      include WebPipe

      plug :hello, -> (conn) { conn.set_response_body('Hello, world!') }
    end
  end
  let(:hello) { -> (conn) { conn.set_response_body('Hello, injected world!') } }

  it 'can inject plug as dependency' do
    pipe_with_injection = pipe.new(plugs: { hello: hello })

    expect(
      pipe_with_injection.call(default_env).last
    ).to eq(['Hello, injected world!'])
  end
end
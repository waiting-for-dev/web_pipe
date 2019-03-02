require 'spec_helper'

RSpec.describe "Injection" do
  let(:pipe) do
    Class.new do
      include WebPipe

      plug :hello, with: -> (conn) { conn.put_response_body('Hello, world!') }
    end
  end
  let(:hello) { -> (conn) { conn.put_response_body('Hello, injected world!') } }

  it 'can inject plug as dependency' do
    pipe_with_injection = pipe.new(hello: hello)

    expect(pipe_with_injection.call({}).last).to eq(['Hello, injected world!'])
  end
end
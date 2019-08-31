# frozen_string_literal: true

require 'spec_helper'
require 'support/conn'

RSpec.describe 'Resolving plugs from a container' do
  Container = Hash[
    'plug.hello' => ->(conn) { conn.set_response_body('Hello, world!') }
  ]

  let(:pipe) do
    Class.new do
      include WebPipe.call(container: Container)

      plug :hello, 'plug.hello'
    end.new
  end

  it 'can resolve operation from a container' do
    expect(pipe.call(default_env).last).to eq(['Hello, world!'])
  end
end

# frozen_string_literal: true

require 'spec_helper'
require 'support/conn'

RSpec.describe 'Resolving plugs from a block' do
  let(:pipe) do
    Class.new do
      include WebPipe

      plug :hello do |conn|
        conn.set_response_body('Hello, world!')
      end
    end.new
  end

  it 'can resolve operation from a block' do
    expect(pipe.call(default_env).last).to eq(['Hello, world!'])
  end
end

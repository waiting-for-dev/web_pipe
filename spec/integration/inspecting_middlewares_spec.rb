# frozen_string_literal: true

require 'spec_helper'
require 'support/conn'
require 'support/middlewares'

RSpec.describe 'Inspecting middlewares' do
  let(:pipe_class) do
    Class.new do
      include WebPipe

      use :first_name, FirstNameMiddleware

      plug :hello do |conn|
        conn.set_response_body('Hello')
      end
    end
  end

  it 'can inspect resolved middlewares' do
    pipe = pipe_class.new

    expect(pipe.middlewares[:first_name][0].middleware).to be(FirstNameMiddleware)
  end

  it 'can inspect injected middlewares' do
    last_name = [LastNameMiddleware, { name: 'Smith' }]
    pipe = pipe_class.new(middlewares: { first_name: last_name })

    expect(pipe.middlewares[:first_name][0].middleware).to be(LastNameMiddleware)
  end
end

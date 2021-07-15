# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

RSpec.describe 'Rack application' do
  include Rack::Test::Methods

  let(:app) do
    Class.new do
      include WebPipe

      plug :hello, lambda { |conn|
        conn
          .set_response_body('Hello, world!')
          .set_status(200)
      }
    end.new
  end

  it 'is a rack application' do
    get '/'

    expect(last_response.body).to eq('Hello, world!')
  end
end

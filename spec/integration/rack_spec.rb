require 'spec_helper'
require 'rack/test'

RSpec.describe Dry::Request::Pipe do
  include Rack::Test::Methods

  let(:app) do
    Class.new do
      include Dry::Request::Pipe

      plug :hello, from: -> (conn) { conn.put_response_body('Hello, world!') }
    end.new
  end

  it 'is a rack application' do
    builder = Rack::Builder.new
    builder.run app

    get '/'

    expect(last_response.body).to eq('Hello, world!')
  end
end
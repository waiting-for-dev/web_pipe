require 'spec_helper'
require 'rack/test'

RSpec.describe Dry::Request::Pipe do
  include Rack::Test::Methods

  let(:steps) { [ -> (conn) { conn.put_response_body('Hello, world!') } ] }
  let(:app) { described_class.new(steps: steps) }

  it 'is a rack application' do
    builder = Rack::Builder.new
    builder.run app

    get '/'

    expect(last_response.body).to eq('Hello, world!')
  end
end
require 'spec_helper'
require 'rack/test'

RSpec.describe "Rack application" do
  include Rack::Test::Methods

  let(:app) do
    Class.new do
      include WebPipe

      plug :hello, with: -> (conn) { conn.put_response_body('Hello, world!') }
    end.new
  end

  it 'is a rack application' do
    builder = Rack::Builder.new
    builder.run app

    get '/'

    expect(last_response.body).to eq('Hello, world!')
  end
end
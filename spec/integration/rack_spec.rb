require 'spec_helper'
require 'rack/test'

RSpec.describe "Rack application" do
  include Rack::Test::Methods

  let(:app) do
    Class.new do
      include WebPipe

      plug :hello, -> (conn) do
        conn.
          set_response_body('Hello, world!').
          set_status(200)
      end
    end.new
  end

  it 'is a rack application' do
    builder = Rack::Builder.new
    builder.run app

    get '/'

    expect(last_response.body).to eq('Hello, world!')
  end
end
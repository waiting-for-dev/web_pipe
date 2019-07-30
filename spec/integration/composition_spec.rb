require 'spec_helper'
require 'support/env'
require 'support/middlewares'

RSpec.describe "Composition" do
  class App
    include WebPipe

    use :first_name, FirstNameMiddleware

    plug :gretting, ->(conn) { conn.put(:greeting, 'Hello') }
  end

  let(:pipe) do
    Class.new do
      include WebPipe

      compose :app, App.new

      use :last_name, LastNameMiddleware, name: 'Doe'
      plug :perform_greeting

      private

      def perform_greeting(conn)
        first_name = conn.env['first_name']
        last_name = conn.env['last_name']
        greeting = conn.fetch(:greeting)
        conn.
          set_response_body(
            "#{greeting} #{first_name} #{last_name}"
          )
      end
    end.new
  end

  it 'using a WebPipe composes its middlewares and plugs' do
    expect(pipe.call(default_env).last[0]).to eq('Hello Joe Doe')
  end
end
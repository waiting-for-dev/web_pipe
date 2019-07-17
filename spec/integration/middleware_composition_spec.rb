require 'spec_helper'
require 'support/env'
require 'support/middlewares'

RSpec.describe "Middleware composition" do
  class AppWithMiddlewares
    include WebPipe

    use :first_name, FirstNameMiddleware
    use :last_name, LastNameMiddleware, name: 'Doe'
  end

  let(:pipe) do
    Class.new do
      include WebPipe

      use :app, AppWithMiddlewares.new

      plug :hello

      private

      def hello(conn)
        first_name = conn.env['first_name']
        last_name = conn.env['last_name']
        conn.
          set_response_body(
            "Hello #{first_name} #{last_name}"
          )
      end
    end.new
  end

  it 'using a WebPipe composes its middlewares' do
    expect(pipe.call(DEFAULT_ENV).last[0]).to eq('Hello Joe Doe')
  end
end
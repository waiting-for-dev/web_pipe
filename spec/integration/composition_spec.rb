require 'spec_helper'
require 'support/env'

RSpec.describe "Composition" do
  class FirstNameMiddleware
    attr_reader :app

    def initialize(app)
      @app = app
    end

    def call(env)
      env['first_name_middleware.name'] = 'Joe'
      app.call(env)
    end
  end

  class LastNameMiddleware
    attr_reader :app
    attr_reader :name

    def initialize(app, name:)
      @app = app
      @name = name
    end

    def call(env)
      env['last_name_middleware.name'] = name
      app.call(env)
    end
  end

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
        first_name = conn.env['first_name_middleware.name']
        last_name = conn.env['last_name_middleware.name']
        greeting = conn.fetch(:greeting)
        conn.
          set_response_body(
            "#{greeting} #{first_name} #{last_name}"
          ).
          set_status(200)
      end
    end.new
  end

  it 'using a WebPipe composes its middlewares and plugs' do
    expect(pipe.call(DEFAULT_ENV).last[0]).to eq('Hello Joe Doe')
  end
end
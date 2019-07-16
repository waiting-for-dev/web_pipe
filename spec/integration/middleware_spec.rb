require 'spec_helper'
require 'support/env'

RSpec.describe "Using rack middlewares" do
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

  let(:pipe) do
    Class.new do
      include WebPipe

      use :first_name, FirstNameMiddleware
      use :last_name, LastNameMiddleware, name: 'Doe'

      plug :hello

      private

      def hello(conn)
        first_name = conn.env['first_name_middleware.name']
        last_name = conn.env['last_name_middleware.name']
        conn.
          set_response_body(
            "Hello #{first_name} #{last_name}"
          ).
          set_status(200)
      end
    end.new
  end

  it 'can use middlewares' do
    expect(pipe.call(DEFAULT_ENV).last[0]).to eq('Hello Joe Doe')
  end
end
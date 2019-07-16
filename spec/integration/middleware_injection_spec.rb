require 'spec_helper'
require 'support/env'

RSpec.describe "Injecting middlewares" do
  class ConfiguredNameMiddleware
    attr_reader :app

    def initialize(app)
      @app = app
    end

    def call(env)
      env['name_middleware.name'] = 'Joe'
      app.call(env)
    end
  end

  class InjectedNameMiddleware
    attr_reader :app

    def initialize(app)
      @app = app
    end

    def call(env)
      env['name_middleware.name'] = 'Alice'
      app.call(env)
    end
  end

  let(:pipe) do
    Class.new do
      include WebPipe

      use :name, ConfiguredNameMiddleware

      plug :hello

      private

      def hello(conn)
        name = conn.env['name_middleware.name']
        conn.
          set_response_body(
            "Hello #{name}"
          ).
          set_status(200)
      end
    end.new(middlewares: { name: [InjectedNameMiddleware] })
  end

  it 'can use middlewares' do
    expect(pipe.call(DEFAULT_ENV).last[0]).to eq('Hello Alice')
  end
end
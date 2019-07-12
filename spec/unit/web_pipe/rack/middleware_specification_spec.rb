require 'spec_helper'
require 'web_pipe'
require 'web_pipe/rack/middleware'
require 'web_pipe/rack/middleware_specification'

RSpec.describe WebPipe::Rack::MiddlewareSpecification do
  describe '.call' do
    Middleware = Class.new do
      def initialize(app, options = nil)
        @app = app
        @options = options
      end

      def call(env)
        env['middleware.options'] = @options
        @app = app.(env)
      end
    end

    context 'when spec is a WebPipe class' do
      it "returns an array with its WebPipe::Rack::Middleware's" do
        Pipe = Class.new do
          include WebPipe

          use Middleware
        end

        expect(described_class.([Pipe])).to be(Pipe.middlewares)
      end
    end

    context 'when spec is a class' do
      it "returns it as a WebPipe::Rack::Middleware with empty options" do
        expect(described_class.([Middleware])).to eq(
          [WebPipe::Rack::Middleware.new(middleware: Middleware, options: [])]
        )
      end
    end

    context 'when spec is a class with options' do
      it "returns it as a WebPipe::Rack::Middleware with given options" do
        expect(described_class.([Middleware, :a])).to eq(
          [WebPipe::Rack::Middleware.new(middleware: Middleware, options: [:a])]
        )
      end
    end
  end
end

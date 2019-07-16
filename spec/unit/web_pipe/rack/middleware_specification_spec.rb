require 'spec_helper'
require 'web_pipe'
require 'web_pipe/rack/middleware'
require 'web_pipe/rack/middleware_specification'

RSpec.describe WebPipe::Rack::MiddlewareSpecification do
  describe '#call' do
    class Middleware
      def initialize(app, options = nil)
        @app = app
        @options = options
      end

      def call(env)
        env['middleware.options'] = @options
        @app = app.(env)
      end
    end

    class Pipe
      include WebPipe

      use :middleware, Middleware
    end

    context 'when spec is a WebPipe class' do
      it "returns an array with its WebPipe::Rack::Middleware's" do
        expect(described_class.new(:name, [Pipe.new]).call).to include(*Pipe.new.middlewares)
      end
    end

    context 'when spec is a class' do
      it "returns it as a WebPipe::Rack::Middleware with empty options" do
        expect(described_class.new(:name, [Middleware]).call).to eq(
          [WebPipe::Rack::Middleware.new(middleware: Middleware, options: [])]
        )
      end
    end

    context 'when spec is a class with options' do
      it "returns it as a WebPipe::Rack::Middleware with given options" do
        expect(described_class.new(:name, [Middleware, :a]).call).to eq(
          [WebPipe::Rack::Middleware.new(middleware: Middleware, options: [:a])]
        )
      end
    end
  end

  describe '#with' do
    let(:name) { :name }
    let(:middleware_specification) { described_class.new(name, [Pipe.new]) }

    let(:new_spec) { [Middleware] }
    let(:new_middleware_specification) { middleware_specification.with(new_spec) }

    it 'returns new instance' do
      expect(new_middleware_specification).not_to be(middleware_specification)
    end

    it 'keeps plug name' do
      expect(new_middleware_specification.name).to be(name)
    end

    it 'replaces spec' do
      expect(new_middleware_specification.spec).to eq(new_spec)
    end
  end

  describe '.inject_and_resolve' do
    it 'inject specs and resolves resulting list of middlewares' do
      middleware_specifications = [
        described_class.new(:middleware_1, [Middleware]),
        described_class.new(:middleware_2, [Pipe])
      ]
      injections = { middleware_2: [Middleware] }

      result = described_class.inject_and_resolve(
        middleware_specifications, injections
      )

      rack_middleware = WebPipe::Rack::Middleware.new(middleware: Middleware, options: [])
      expect(result.freeze).to eq([rack_middleware]*2.freeze)
    end
  end
end

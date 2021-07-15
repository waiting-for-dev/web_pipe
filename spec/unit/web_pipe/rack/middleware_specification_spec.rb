# frozen_string_literal: true

require 'spec_helper'
require 'web_pipe'
require 'web_pipe/rack_support/middleware'
require 'web_pipe/rack_support/middleware_specification'
require 'support/middlewares'

RSpec.describe WebPipe::RackSupport::MiddlewareSpecification do
  let(:pipe) do
    Class.new do
      include WebPipe

      use :middleware, FirstNameMiddleware
    end
  end

  describe '#call' do
    context 'when spec responds to to_middlewares' do
      it "returns an array with its WebPipe::Rack::Middleware's" do
        expect(described_class.new(name: :name, spec: [pipe.new]).call).to include(
          WebPipe::RackSupport::Middleware.new(middleware: FirstNameMiddleware, options: [])
        )
      end
    end

    context 'when spec is a class' do
      it 'returns it as a WebPipe::RackSupport::Middleware with empty options' do
        expect(described_class.new(name: :name, spec: [FirstNameMiddleware]).call).to eq(
          [WebPipe::RackSupport::Middleware.new(middleware: FirstNameMiddleware, options: [])]
        )
      end
    end

    context 'when spec is a class with options' do
      it 'returns it as a WebPipe::RackSupport::Middleware with given options' do
        expect(described_class.new(name: :name, spec: [LastNameMiddleware, { name: 'Joe' }]).call).to eq(
          [WebPipe::RackSupport::Middleware.new(middleware: LastNameMiddleware, options: [name: 'Joe'])]
        )
      end
    end
  end

  describe '#with' do
    let(:name) { :name }
    let(:middleware_specification) { described_class.new(name: name, spec: [pipe.new]) }

    let(:new_spec) { [FirstNameMiddleware] }
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

  describe '.inject' do
    it 'inject specs' do
      spec1 = described_class.new(name: :middleware1, spec: [FirstNameMiddleware])
      spec2 = described_class.new(name: :middleware2, spec: [pipe.new])
      middleware_specifications = [
        spec1,
        spec2
      ]
      injections = { middleware2: [FirstNameMiddleware] }

      result = described_class.inject(
        middleware_specifications, injections
      )

      expect(result.map(&:spec)).to eq([[FirstNameMiddleware], [FirstNameMiddleware]])
    end
  end
end

# frozen_string_literal: true

require "dry/struct"

module WebPipe
  module RackSupport
    # @api private
    class MiddlewareSpecification < Dry::Struct
      Name = Types::Strict::Symbol.constructor(&:to_sym)

      Spec = Types::Strict::Array

      Injections = Types::Strict::Hash.map(
        Name, Spec
      ).default(Types::EMPTY_HASH)

      attribute :name, Name

      attribute :spec, Spec

      def self.inject(middleware_specifications, injections)
        middleware_specifications.map do |middleware_spec|
          inject_middleware(middleware_spec, injections)
        end
      end

      def self.inject_middleware(middleware_spec, injections)
        name = middleware_spec.name
        if injections.key?(name)
          middleware_spec.with(injections[name])
        else
          middleware_spec
        end
      end

      def call
        klass_or_pipe = spec[0]
        options = spec[1..] || Types::EMPTY_ARRAY
        if klass_or_pipe.respond_to?(:to_middlewares)
          klass_or_pipe.to_middlewares
        elsif klass_or_pipe.is_a?(Class)
          [Middleware.new(middleware: klass_or_pipe, options: options)]
        end
      end

      def with(new_spec)
        new(spec: new_spec)
      end
    end
  end
end

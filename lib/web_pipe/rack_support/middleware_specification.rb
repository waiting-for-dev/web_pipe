# frozen_string_literal: true

require 'dry/struct'
require 'web_pipe/rack_support/middleware'
require 'web_pipe/types'

module WebPipe
  module RackSupport
    # Specification on how to resolve {Rack::Middleware}'s.
    #
    # Rack middlewares can be specified in two ways:
    #
    # - As an array where fist element is a rack middleware class
    # while the rest of elements are its initialization options.
    # - A single element array where it is an instance of a class
    # including {WebPipe}. This specifies all {RackSupport::Middlewares} for
    # that {WebPipe}.
    #
    # @api private
    class MiddlewareSpecification < Dry::Struct
      # Type for the name given to a middleware.
      Name = Types::Strict::Symbol.constructor(&:to_sym)

      # Poor type for the specification to resolve a rack middleware.
      Spec = Types::Strict::Array

      # Schema expected to inject middleware specifications.
      #
      # @see #inject_and_resolve
      Injections = Types::Strict::Hash.map(
        RackSupport::MiddlewareSpecification::Name, RackSupport::MiddlewareSpecification::Spec
      ).default(Types::EMPTY_HASH)

      # @!attribute [r] name
      #   @return [Name[]]
      attribute :name, Name

      # @!attribute [r] spec
      #   @return [Spec[]]
      attribute :spec, Spec

      # Change spec's present in `injections` and resolves.
      #
      # @param middleware_specifications [Array<MiddlewareSpecification>]
      # @param injections [Injections[]]
      #
      # @return [Array<RackSupport::Middleware>]
      def self.inject_and_resolve(middleware_specifications, injections)
        middleware_specifications.map do |spec|
          if injections.key?(spec.name)
            spec.with(injections[spec.name])
          else
            spec
          end.call
        end.flatten
      end

      # Resolves {RackSupport::Middlewares} from given specification.
      #
      # @return [Array<RackSupport::Middleware>]
      def call
        klass = spec[0]
        options = spec[1..-1] || Types::EMPTY_ARRAY
        if klass.is_a?(WebPipe)
          klass.middlewares
        elsif klass.is_a?(Class)
          [Middleware.new(middleware: klass, options: options)]
        end
      end

      # Returns new instance with {#spec} replaced.
      #
      # @param new_spec [Spec[]]
      #
      # @return [MiddlewareSpecification]
      def with(new_spec)
        new(spec: new_spec)
      end
    end
  end
end

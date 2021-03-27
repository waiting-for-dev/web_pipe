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
      # @return [Hash<Name[], Array<RackSupport::Middleware>]
      def self.inject_and_resolve(middleware_specifications, injections)
        Hash[
          middleware_specifications.map do |middleware_spec|
            inject_and_resolve_middleware(middleware_spec, injections)
          end
        ]
      end

      def self.inject_and_resolve_middleware(middleware_spec, injections)
        name = middleware_spec.name
        [
          name,
          if injections.key?(name)
            middleware_spec.with(injections[name])
          else
            middleware_spec
          end.call
        ]
      end
      private_class_method :inject_and_resolve_middleware

      # Resolves {RackSupport::Middlewares} from given specification.
      #
      # @return [Array<RackSupport::Middleware>]
      def call
        klass = spec[0]
        options = spec[1..] || Types::EMPTY_ARRAY
        case klass
        when WebPipe
          klass.middlewares.values
        when Class
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

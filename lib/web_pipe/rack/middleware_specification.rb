require 'web_pipe/rack/middleware'
require 'web_pipe/types'

module WebPipe
  module Rack
    # Specification on how to resolve {Rack::Middleware}'s.
    #
    # Rack middlewares can be specified in two ways:
    #
    # - As an array where fist element is a rack middleware class
    # while the rest of elements are its initialization options.
    # - A single element array where it is a class including
    # {WebPipe}. This specifies all {Rack::Middlewares} configured
    # for that {WebPipe}.
    #
    # @api private
    module MiddlewareSpecification
      # Resolves {Rack::Middlewares} from given specification.
      #
      # @param spec [Array]
      # @return [Array<Rack::Middleware>]
      def self.call(spec)
        klass = spec[0]
        options = spec[1..-1] || Types::EMPTY_ARRAY
        if klass.included_modules.include?(WebPipe)
          klass.middlewares
        elsif klass.is_a?(Class)
          [Middleware.new(middleware: klass, options: options)]
        end
      end
    end
  end
end

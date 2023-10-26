# frozen_string_literal: true

require "web_pipe/types"
require "dry/struct"

module WebPipe
  module RackSupport
    # Wrapper for a rack middleware.
    #
    # Simple data structure to represent a rack middleware class with
    # its initialization options.
    class Middleware < Dry::Struct
      # Type for a rack middleware class.
      MiddlewareClass = Types.Instance(Class)

      # Type for the options to initialize a rack middleware.
      Options = Types::Strict::Array

      # @!attribute [r] middleware
      #   @return [MiddlewareClass[]] Rack middleware
      attribute :middleware, MiddlewareClass

      # @!attribute [r] options
      # @return [Options[]] Options to initialize the rack middleware
      attribute :options, Options
    end
  end
end

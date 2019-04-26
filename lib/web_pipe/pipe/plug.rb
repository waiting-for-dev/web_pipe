require 'dry/initializer'
require 'web_pipe/pipe/types'
require 'web_pipe/pipe/errors'

module WebPipe
  module Pipe
    # A plug is a specification to resolve a callable object.
    #
    # It is initialized with a `name` and a `spec` and, on resolution
    # time, is called with a `container` and an `object` to act in the
    # following fashion:
    #
    # - When the `spec` responds to `#call`, it is returned itself as
    # the callable object.
    # - When the `spec` is `nil`, then a {Proc} wrapping a method with
    # the plug `name` in `object` is returned.
    # - Otherwise, `spec` is taken as the key to resolve the operation
    # from the `container`.
    #
    # @private
    class Plug
      include Dry::Initializer.define -> do
        # @!attribute [r] name
        #   @return [Symbol, String]
        param :name, Types::Strict::Symbol | Types::Strict::String

        # @!attribute [r] spec
        #   @return [Types::PlugSpec]
        param :spec, Types::PlugSpec
      end

      # Creates a new instance with given `spec` but keeping `name`.
      #
      # @param new_spec [Types::PlugSpec]
      # @return [self]
      def with(new_spec)
        self.class.new(name, new_spec)
      end

      # Resolves the operation.
      #
      # @param container [Types::Container]
      # @param object [Object]
      #
      # @return [Types::Operation]
      # @raise [InvalidPlugError] When nothing callable is resolved.
      def call(container, pipe)
        if spec.respond_to?(:call)
          spec
        elsif spec.nil?
          pipe.method(name)
        elsif container[spec] && container[spec].respond_to?(:call)
          container[spec]
        else
          raise InvalidPlugError.new(name)
        end
      end

      # Change `plugs` spec's present in `injections` and resolves.
      #
      # @param plugs [Array<Plug>]
      # @param injections [Hash<Symbol, Types::PlugSpec]
      # @container container [Types::Container]
      # @object [Object]
      #
      # @return [Array<Types::Operation>]
      def self.inject_and_resolve(plugs, injections, container, object)
        plugs.map do |plug|
          if injections.has_key?(plug.name)
            plug.with(injections[plug.name])
          else
            plug
          end.(container, object)
        end
      end
    end
  end
end
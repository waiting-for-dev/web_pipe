require 'dry/initializer'
require 'web_pipe/pipe/types'
require 'web_pipe/pipe/errors'
require 'web_pipe/pipe/app'

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
      # Type for the name of a plug.
      Name = Types::Strict::Symbol | Types::Strict::String

      # Type for the spec to resolve and {App::Operation} on a
      # {Conn::Struct} used by {Pipe::Plug}.
      Spec = App::Operation | Types.Constant(nil) | Types::Strict::String | Types::Strict::Symbol

      # Type for an instance of self.
      Instance = Types.Instance(self)

      include Dry::Initializer.define -> do
        # @!attribute [r] name
        #   @return [Name[]]
        param :name, Name

        # @!attribute [r] spec
        #   @return [Spec[]]
        param :spec, Spec
      end

      # Creates a new instance with given `spec` but keeping `name`.
      #
      # @param new_spec [Spec[]]
      # @return [self]
      def with(new_spec)
        self.class.new(name, new_spec)
      end

      # Resolves the operation.
      #
      # @param container [Types::Container[]]
      # @param object [Object]
      #
      # @return [Operation[]]
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
      # @param plugs [Array<Plug[]>]
      # @param injections [InstanceMethods::Injections[]]
      # @container container [Types::Container[]]
      # @object [Object]
      #
      # @return [Array<Operation[]>]
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
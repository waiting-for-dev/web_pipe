require 'web_pipe/types'
require 'web_pipe/conn_support/composition'

module WebPipe
  # A plug is a specification to resolve a callable object.
  #
  # It is initialized with a {Name} and a {Spec} and, on resolution
  # time, is called with a {Types::Container} and an {Object} to act
  # in the following fashion:
  #
  # - When the spec responds to `#call`, it is returned itself as the
  # callable object.
  # - When the spec is `nil`, then a {Proc} wrapping a method with the
  # plug name in `object` is returned.
  # - Otherwise, spec is taken as the key to resolve the operation
  # from the `container`.
  #
  # @api private
  class Plug
    # Error raised when no operation can be resolved from a {Spec}.
    class InvalidPlugError < ArgumentError
      # @param name [Any] Name for the plug that can't be resolved
      def initialize(name)
        super(
          <<~eos
            Plug with name +#{name}+ is invalid. It must be something
            callable, an instance method when no operation is given,
            or something callable registered in the container."
          eos
        )
      end
    end

    # Type for the name of a plug.
    Name = Types::Strict::Symbol.constructor(&:to_sym)

    # Type for the spec to resolve and
    # {ConnSupport::Composition::Operation} on a {Conn} used by
    # {Plug}.
    Spec = ConnSupport::Composition::Operation |
           Types.Constant(nil) |
           Types::Strict::String |
           Types::Strict::Symbol

    # Type for an instance of self.
    Instance = Types.Instance(self)

    # Schema expected to inject plugs.
    #
    # @see #inject_and_resolve
    Injections = Types::Strict::Hash.map(
      Plug::Name, Plug::Spec
    ).default(Types::EMPTY_HASH)

    # @!attribute [r] name
    #   @return [Name[]]
    attr_reader :name

    # @!attribute [r] spec
    #   @return [Spec[]]
    attr_reader :spec

    def initialize(name, spec)
      @name = Name[name]
      @spec = Spec[spec]
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
    # @return [ConnSupport::Composition::Operation[]]
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
    # @param injections [InstanceMethods::PlugInjections[]]
    # @container container [Types::Container[]]
    # @object [Object]
    #
    # @return [Array<ConnSupport::Composition::Operation[]>]
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
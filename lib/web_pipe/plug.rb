# frozen_string_literal: true

require "dry/struct"

module WebPipe
  # @api private
  class Plug < Dry::Struct
    # Raised when the specification for an operation is invalid.
    class InvalidPlugError < ArgumentError
      def initialize(name)
        super(
          <<~MSG
            Plug with name +#{name}+ can't be resolved. You must provide
            something responding to `#call` or `#to_proc`, or a key for
            something registered in the container obeying those exact
            constraints. If nothing is given, it's expected to be a method
            defined in the context object.
          MSG
        )
      end
    end
    Name = Types::Strict::Symbol.constructor(&:to_sym)

    Spec = Types.Interface(:call) |
           Types.Interface(:to_proc) |
           Types.Constant(nil) |
           Types::Strict::String |
           Types::Strict::Symbol

    Injections = Types::Strict::Hash.map(
      Name, Spec
    ).default(Types::EMPTY_HASH)

    attribute :name, Name

    attribute :spec, Spec

    def with(new_spec)
      new(spec: new_spec)
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def call(container, context)
      if spec.respond_to?(:to_proc) && !spec.is_a?(Symbol)
        spec.to_proc
      elsif spec.respond_to?(:call)
        spec
      elsif spec.nil?
        context.method(name)
      elsif container[spec]
        with(container[spec]).(container, context)
      else
        raise InvalidPlugError, name
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    def self.inject(plugs, injections)
      plugs.map do |plug|
        inject_plug(plug, injections)
      end
    end

    def self.inject_plug(plug, injections)
      name = plug.name
      if injections.key?(name)
        plug.with(injections[name])
      else
        plug
      end
    end
  end
end

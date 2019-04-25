module WebPipe
  module Pipe
    # Error raised when no operation can be built through the {DSL} for
    # building {Plug}.
    class InvalidPlugError < ArgumentError
      def initialize(name)
        super(
          <<~eos
            Plug with name #{name} is invalid. It must be something
            callable, an instance method when `with:` is not given, or
            something callable registered in the container."
          eos
        )
      end
    end

    # Error raised when an operation returns something that is not a
    # {Conn::Clean} or a {Conn::Dirty}.
    class InvalidOperationResult < RuntimeError
      def initialize(returned)
        super(
          <<~eos
            An operation returned #{returned.inspect}. To be valid, an
            operation must return whether a WebPipe::Conn::Clean or a
            WebPipe::Conn:Dirty.
          eos
        )
      end
    end
  end
end
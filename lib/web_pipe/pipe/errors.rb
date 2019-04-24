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
  end
end
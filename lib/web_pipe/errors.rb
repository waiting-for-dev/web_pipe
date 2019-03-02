module WebPipe
  class InvalidPlugError < ArgumentError
    def initialize(name)
      super("Plug with name #{name} is invalid. It must be something callable, an instance method when `with:` is not given, or something callable registered in the container.")
    end
  end
end
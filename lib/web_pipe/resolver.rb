module WebPipe
  class Resolver
    attr_reader :container
    attr_reader :pipe

    def initialize(container, pipe)
      @container = container
      @pipe = pipe
    end

    def call(name, operation)
      case operation
      when String
        container[operation]
      when nil
        pipe.method(name)
      else
        operation
      end
    end
  end
end
module WebPipe
  class Resolver
    attr_reader :container
    attr_reader :pipe

    def initialize(container, pipe)
      @container = container
      @pipe = pipe
    end

    def call(name, step)
      case step
      when String
        container[step]
      when nil
        pipe.method(name)
      else
        step
      end
    end
  end
end
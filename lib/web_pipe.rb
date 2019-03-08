require 'web_pipe/pipe/builder'

module WebPipe
  # Including just delegates to an instance of `Builder`, so
  # `Builder#included` is finally called.
  def self.included(klass)
    klass.include(call())
  end

  def self.call(*args)
    Pipe::Builder.new(*args)
  end
end
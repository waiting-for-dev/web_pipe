require 'web_pipe/builder'

module WebPipe
  # Including just delegates to an instance of `Builder`, so
  # `Builder#included` is finally called.
  def self.included(klass)
    klass.include(WebPipe::call())
  end

  def self.call(*args)
    Builder.new(*args)
  end
end
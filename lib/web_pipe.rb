require 'web_pipe/builder'

module WebPipe
  # When this module is included, `WebPipe.included` just delegates to an
  # instance of `Builder`, so `Builder#instance` is finally called.
  def self.included(klass)
    klass.include(WebPipe::call())
  end

  def self.call(*args)
    Builder.new(*args)
  end
end
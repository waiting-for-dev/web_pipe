require 'web_pipe/dsl/builder'

# See [the
# README](https://github.com/waiting-for-dev/web_pipe/blob/master/README.md)
# for a general overview of this library.
module WebPipe
  # Including just delegates to an instance of `Builder`, so
  # `Builder#included` is finally called.
  def self.included(klass)
    klass.include(call())
  end

  def self.call(*args)
    DSL::Builder.new(*args)
  end
end
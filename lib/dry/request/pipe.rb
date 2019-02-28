require 'dry/request/builder'

module Dry
  module Request
    # When this module is included, `Pipe.included` just delegates to an
    # instance of `Builder`, so `Builder#instance` is finally called.
    module Pipe
      def self.included(klass)
        klass.include(Dry::Request.Pipe())
      end
    end

    def self.Pipe(*args)
      Builder.new(*args)
    end
  end
end
require 'dry/request/builder'

module Dry
  module Request
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
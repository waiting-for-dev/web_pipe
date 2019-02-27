module Dry
  module Request
    class Resolver
      attr_reader :container

      def initialize(container)
        @container = container
      end

      def call(step)
        case step
        when String
          container[step]
        else
          step
        end
      end
    end
  end
end
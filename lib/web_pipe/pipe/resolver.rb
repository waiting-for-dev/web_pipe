require 'web_pipe/pipe/errors'

module WebPipe
  module Pipe
    class Resolver
      attr_reader :container
      attr_reader :pipe

      def initialize(container, pipe)
        @container = container
        @pipe = pipe
      end

      def call(name, operation)
        if operation.respond_to?(:call)
          operation
        elsif operation.nil?
          pipe.method(name)
        elsif container[operation] && container[operation].respond_to?(:call)
          container[operation]
        else
          raise InvalidPlugError.new(name)
        end
      end
    end
  end
end
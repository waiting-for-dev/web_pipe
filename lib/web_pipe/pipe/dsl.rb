module WebPipe
  module Pipe
    # Defines the DSL for the pipe class.
    #
    # @private
    class DSL
      attr_reader :middlewares
      attr_reader :plugs

      def initialize(middlewares, plugs)
        @middlewares = middlewares
        @plugs = plugs
      end

      def use(middleware, *args)
        middlewares << [middleware, args]
      end

      def plug(name, with: nil)
        plugs << [name, with]
      end
    end
  end
end
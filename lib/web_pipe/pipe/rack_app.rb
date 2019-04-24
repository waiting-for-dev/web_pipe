require 'rack'

module WebPipe
  module Pipe
    # Helper module to build a rack application with middlewares.
    #
    # This, in fact, can be used for any kind of rack application, not
    # just a pipe, and here it serves to wrap rack API.
    #
    # @private
    class RackApp
      attr_reader :builder
      
      def initialize(middlewares, app)
        @builder = build_rack_app(middlewares, app)
      end

      def call(env)
        builder.call(env)
      end

      private

      def build_rack_app(middlewares, app)
        Rack::Builder.new.tap do |b|
          middlewares.each do |middleware, args|
            b.use(middleware, *args)
          end
          b.run(app)
        end
      end
    end
  end
end
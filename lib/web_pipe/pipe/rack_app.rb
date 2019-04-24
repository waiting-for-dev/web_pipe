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
      
      def initialize(rack_middlewares, app)
        @builder = build_rack_app(rack_middlewares, app)
      end

      def call(env)
        builder.call(env)
      end

      private

      def build_rack_app(rack_middlewares, app)
        Rack::Builder.new.tap do |b|
          rack_middlewares.each do |middleware|
            b.use(middleware.middleware, *middleware.options)
          end
          b.run(app)
        end
      end
    end
  end
end
require 'web_pipe/conn/struct'
require 'web_pipe/conn/builder'
require 'web_pipe/pipe/resolver'
require 'web_pipe/pipe/app'
require 'rack'

module WebPipe
  module Pipe
    # Instance methods for the pipe.
    #
    # The pipe state can be accessed through the pipe class, which
    # has been configured through `ClassContext`.
    #
    # @private
    module InstanceMethods
      attr_reader :middlewares
      attr_reader :plugs
      attr_reader :container
      attr_reader :resolver
      
      def initialize(**kwargs)
        @plugs = self.class.plugs.map do |(name, op)|
          kwargs.has_key?(name) ? [name, kwargs[name]] : [name, op]
        end
        @middlewares = self.class.middlewares
        @container = self.class.container
        @resolver = Resolver.new(container, self)
      end
      
      def call(env)
        rack_builder = Rack::Builder.new.tap do |b|
          middlewares.each do |middleware, args|
            b.use(middleware, *args)
          end
        end
        rack_builder.run(App.new(plugs, resolver))
        rack_builder.call(env)
      end
    end
  end
end
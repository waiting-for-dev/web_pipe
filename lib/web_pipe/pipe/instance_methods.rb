require 'web_pipe/conn/struct'
require 'web_pipe/conn/builder'
require 'web_pipe/pipe/resolver'
require 'web_pipe/pipe/app'
require 'web_pipe/pipe/rack_app'

module WebPipe
  module Pipe
    # Instance methods for the pipe.
    #
    # The pipe state can be accessed through the pipe class, which
    # has been configured through `ClassContext`.
    #
    # @private
    module InstanceMethods
      attr_reader :rack_app
      
      def initialize(**kwargs)
        middlewares = self.class.middlewares
        container = self.class.container
        plugs = self.class.plugs.map do |(name, op)|
          kwargs.has_key?(name) ? [name, kwargs[name]] : [name, op]
        end
        resolver = Resolver.new(container, self)
        app = App.new(plugs, resolver)
        @rack_app = RackApp.new(middlewares, app)
      end
      
      def call(env)
        rack_app.call(env)
      end
    end
  end
end
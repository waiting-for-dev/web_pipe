require 'web_pipe/conn/struct'
require 'web_pipe/conn/builder'
require 'web_pipe/pipe/app'
require 'web_pipe/pipe/rack_app'

module WebPipe
  module Pipe
    # Instance methods for the pipe.
    #
    # It is from here that you get the rack application you can route
    # to. The initialization phase gives you the chance to inject any
    # of the plugs, while the instance you get has the `#call` method
    # expected by rack.
    #
    # The pipe state can be accessed through the pipe class, which
    # has been configured through {ClassContext}.
    #
    # @private
    module InstanceMethods
      # !@attribute rack_app
      #   @return [RackApplication]
      attr_reader :rack_app
      
      # @params injected_plugs [Hash<Symbol, [#call, nil, String]>]
      #   Injected plugs that allow overriding what has been configured.
      def initialize(**injected_plugs)
        middlewares = self.class.middlewares
        container = self.class.container
        operations = self.class.plugs.map do |plug|
          if injected_plugs.has_key?(plug.name)
            plug.with(injected_plugs[plug.name]).(container, self)
          else
            plug.(container, self)
          end
        end
        app = App.new(operations)
        @rack_app = RackApp.new(middlewares, app)
      end
      
      # Expected interface for rack.
      #
      # @param env [Hash] Rack env
      #
      # @return [Array] Rack response
      def call(env)
        rack_app.call(env)
      end
    end
  end
end
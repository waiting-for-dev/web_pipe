require 'web_pipe/conn/struct'
require 'web_pipe/conn/builder'
require 'web_pipe/pipe/resolver'
require 'dry/monads/result'
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
      
      include Dry::Monads::Result::Mixin
      
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

        app = ->(env) do
          conn = Success(Conn::Builder.call(env))
          
          last_conn = plugs.reduce(conn) do |prev_conn, (name, plug)|
            prev_conn.bind do |c|
              result = resolver.(name, plug).(c)
              case result
              when Conn::Clean
                Success(result)
              when Conn::Dirty
                Failure(result)
              else
                raise RuntimeError
              end
            end
          end
          
          case last_conn
          when Dry::Monads::Success
            last_conn.success.rack_response
          when Dry::Monads::Failure
            last_conn.failure.rack_response
          end
        end

        rack_builder.run(app)
        rack_builder.call(env)
      end
    end
  end
end
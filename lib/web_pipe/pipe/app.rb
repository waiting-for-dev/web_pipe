require 'dry/monads/result'

module WebPipe
  module Pipe
    class App
      include Dry::Monads::Result::Mixin

      attr_reader :operations

      def initialize(operations)
        @operations = operations
      end

      def call(env)
        conn = Success(Conn::Builder.call(env))
        
        last_conn = operations.reduce(conn) do |prev_conn, operation|
          prev_conn.bind do |c|
            result = operation.(c)
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
    end
  end
end
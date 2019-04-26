require 'dry/initializer'
require 'dry/monads/result'
require 'web_pipe/pipe/types'
require 'web_pipe/pipe/errors'
require 'dry/monads/result/extensions/either'

Dry::Monads::Result.load_extensions(:either)

module WebPipe
  module Pipe
    # Rack application built around applying a pipe of {#operations} to
    # a {Conn::Struct}.
    #
    # A rack application is something callable accepting rack's `env`
    # as argument and returning a rack response. So, the workflow
    # followed to build it is:
    #
    # - Take rack's `env` and create a `{Conn::Struct}` from here.
    # - Starting from it, apply the pipe of operations (anything
    # callable accepting a `{Conn::Struct}` and returning a
    # `{Conn::Struct}`.
    # - Convert last `{Conn::Struct}` back to a rack response and
    # return it.
    #
    # {Conn::Struct} can itself be of two different types (subclasses
    # of it}: `{Conn::Clean}` and `{Conn::Dirty}`. The pipe is stopped
    # whenever the stack is emptied or a `{Conn::Dirty}` is returned
    # in any of the steps.
    class App
      include Dry::Monads::Result::Mixin

      include Dry::Initializer.define -> do
        # @!attribute [r] operations
        #   @return [Array<Types::Operation>]
        param :operations, type: Types::Strict::Array.of(Types::Operation)
      end

      # @param env [Hash] Rack env
      #
      # @return env [Array] Rack response
      def call(env)
        extract_rack_response(
          apply_operations(
            conn_from_env(
              env
            )
          )
        )
      end

      private

      def conn_from_env(env)
        Success(
          Conn::Builder.(env)
        )
      end

      def apply_operations(conn)
        operations.reduce(conn) do |new_conn, operation|
          new_conn.bind { |c| apply_operation(c, operation) }
        end
      end

      def apply_operation(conn, operation)
        result = operation.(conn)
        case result
        when Conn::Clean
          Success(result)
        when Conn::Dirty
          Failure(result)
        else
          raise InvalidOperationResult.new(result)
        end
      end

      def extract_rack_response(conn)
        extract_proc = :rack_response.to_proc

        conn.either(extract_proc, extract_proc)
      end
    end
  end
end
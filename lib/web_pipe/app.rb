require 'dry/initializer'
require 'dry/monads/result'
require 'web_pipe/types'
require 'web_pipe/conn'
require 'web_pipe/conn_support/builder'
require 'dry/monads/result/extensions/either'

Dry::Monads::Result.load_extensions(:either)

module WebPipe
  # Rack application built around applying a pipe of {#operations} to
  # a {Conn}.
  #
  # A rack application is something callable accepting rack's `env`
  # as argument and returning a rack response. So, the workflow
  # followed to build it is:
  #
  # - Take rack's `env` and create a `{Conn}` from here.
  # - Starting from it, apply the pipe of operations (anything
  # callable accepting a `{Conn}` and returning a `{Conn}`.
  # - Convert last `{Conn}` back to a rack response and
  # return it.
  #
  # {Conn} can itself be of two different types (subclasses of it}:
  # `{Conn::Clean}` and `{Conn::Dirty}`. The pipe is stopped
  # whenever the stack is emptied or a `Conn::Dirty` is
  # returned in any of the steps.
  class App
    # Type for an operation.
    #
    # It should be anything callable expecting a {Conn} and
    # returning a {Conn}.
    Operation = Types.Contract(:call)

    # Type for a rack environment.
    RackEnv = Types::Strict::Hash

    # Error raised when an {Operation} returns something that is not a
    # {Conn}.
    class InvalidOperationResult < RuntimeError
      def initialize(returned)
        super(
          <<~eos
            An operation returned +#{returned.inspect}+. To be valid,
            an operation must return whether a
            WebPipe::Conn::Clean or a WebPipe::Conn::Dirty.
          eos
        )
      end
    end

    include Dry::Monads::Result::Mixin

    include Dry::Initializer.define -> do
      # @!attribute [r] operations
      #   @return [Array<Operation[]>]
      param :operations, type: Types.Array(Operation)
    end

    # @param env [Hash] Rack env
    #
    # @return env [Array] Rack response
    def call(env)
      extract_rack_response(
        apply_operations(
          conn_from_env(
            RackEnv[env]
          )
        )
      )
    end

    private

    def conn_from_env(env)
      Success(
        ConnSupport::Builder.(env)
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
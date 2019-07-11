require 'dry/initializer'
require 'web_pipe/types'
require 'web_pipe/conn'
require 'web_pipe/conn_support/builder'
require 'web_pipe/conn_support/composition'

module WebPipe
  # Rack application built around applying a pipe of {Operation} to
  # a {Conn}.
  #
  # A rack application is something callable accepting rack's `env`
  # as argument and returning a rack response. So, the workflow
  # followed to build it is:
  #
  # - Take rack's `env` and create a {Conn} from here.
  # - Starting from it, apply the pipe of operations (anything
  # callable accepting a {Conn} and returning a {Conn}).
  # - Convert last {Conn} back to a rack response and
  # return it.
  #
  # {Conn} can itself be of two different types (subclasses of it}:
  # {Conn::Clean} and {Conn::Dirty}. The pipe is stopped
  # whenever the stack is emptied or a {Conn::Dirty} is
  # returned in any of the steps.
  class App
    # Type for a rack environment.
    RackEnv = Types::Strict::Hash

    include Dry::Monads::Result::Mixin

    include Dry::Initializer.define -> do
      # @!attribute [r] operations
      #   @return [Array<Operation[]>]
      param :operations, type: Types.Array(
              ConnSupport::Composition::Operation
            )
    end

    # @param env [Hash] Rack env
    #
    # @return env [Array] Rack response
    # @raise ConnSupport::Composition::InvalidOperationResult when an
    # operation does not return a {Conn}
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
      ConnSupport::Builder.(env)
    end

    def apply_operations(conn)
      ConnSupport::Composition.new(operations).call(conn)
    end

    def extract_rack_response(conn)
      conn.rack_response
    end
  end
end
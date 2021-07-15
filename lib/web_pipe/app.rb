# frozen_string_literal: true

require 'web_pipe/conn'
require 'web_pipe/conn_support/builder'
require 'web_pipe/conn_support/composition'

module WebPipe
  # Rack app built from a chain of functions that take and return a
  # {WebPipe::Conn}.
  #
  # This is the abstraction encompassing a rack application built only with the
  # functions on {WebPipe::Conn}. {WebPipe::RackSupport::AppWithMiddlewares}
  # takes middlewares also into account.
  #
  # A rack application is something callable that takes the rack environment as
  # an argument, and returns a rack response. So, this class needs to:
  #
  # - Take rack's environment and create a {WebPipe::Conn} struct from there.
  # - Starting from the initial struct, apply the pipe of functions.
  # - Convert the last {WebPipe::Conn} back to a rack response.
  #
  # {WebPipe::Conn} can itself be of two different types (subclasses of it}:
  # {Conn::Ongoing} and {Conn::Halted}. The pipe is stopped on two scenarios:
  #
  # - The end of the pipe is reached.
  # - One function returns a {Conn::Halted}.
  class App
    include Dry::Monads::Result::Mixin

    # @!attribute [r] operations
    #   @return [Array<Proc>]
    attr_reader :operations

    # @param operations [Array<Proc>]
    def initialize(operations)
      @operations = operations
    end

    # @param env [Hash] Rack environment
    #
    # @return env [Array] Rack response
    # @raise ConnSupport::Composition::InvalidOperationResult when an
    # operation doesn't return a {WebPipe::Conn}
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
      ConnSupport::Builder.call(env)
    end

    def apply_operations(conn)
      ConnSupport::Composition.new(operations).call(conn)
    end

    def extract_rack_response(conn)
      conn.rack_response
    end
  end
end

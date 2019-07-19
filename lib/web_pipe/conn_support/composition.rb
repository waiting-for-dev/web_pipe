require 'dry/monads/result'
require 'web_pipe/types'
require 'web_pipe/conn'
require 'dry/monads/result/extensions/either'

Dry::Monads::Result.load_extensions(:either)

module WebPipe
  module ConnSupport
    # Composition of a pipe of {Operation} on a {Conn}.
    #
    # It represents the composition of a series of functions which
    # take a {Conn} as argument and return a {Conn}.
    #
    # However, {Conn} can itself be of two different types (subclasses
    # of it): a {Conn::Clean} or a {Conn::Dirty}. On execution time,
    # the composition is stopped whenever the stack is emptied or a
    # {Conn::Dirty} is returned in any of the steps.
    class Composition
      # Type for an operation.
      #
      # It should be anything callable expecting a {Conn} and
      # returning a {Conn}.
      Operation = Types.Interface(:call)

      # Error raised when an {Operation} returns something that is not
      # a {Conn}.
      class InvalidOperationResult < RuntimeError
        # @param returned [Any] What was returned from the {Operation}
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

      # @!attribute [r] operations
      #   @return [Array<Operation[]>]
      attr_reader :operations

      def initialize(operations)
        @operations = Types.Array(Operation)[operations]
      end

      # @param conn [Conn]
      # @return [Conn]
      # @raise InvalidOperationResult when an operation does not
      # return a {Conn}
      def call(conn)
        extract_result(
          apply_operations(
            conn
          )
        )
      end

      private

      def apply_operations(conn)
        operations.reduce(Success(conn)) do |new_conn, operation|
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

      def extract_result(result)
        extract_proc = :itself.to_proc

        result.either(extract_proc, extract_proc)
      end
    end
  end
end
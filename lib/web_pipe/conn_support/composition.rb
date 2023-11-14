# frozen_string_literal: true

require "dry/monads"

module WebPipe
  module ConnSupport
    # @api private
    class Composition
      # Raised when operation doesn't return a {WebPipe::Conn}.
      class InvalidOperationResult < RuntimeError
        def initialize(returned)
          super(
            <<~MSG
              An operation returned +#{returned.inspect}+. To be valid,
              an operation must return whether a
              WebPipe::Conn::Ongoing or a WebPipe::Conn::Halted.
            MSG
          )
        end
      end

      include Dry::Monads[:result]

      attr_reader :operations

      def initialize(operations)
        @operations = operations
      end

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
        when Conn::Ongoing
          Success(result)
        when Conn::Halted
          Failure(result)
        else
          raise InvalidOperationResult, result
        end
      end

      def extract_result(result)
        extract_proc = :itself.to_proc

        result.either(extract_proc, extract_proc)
      end
    end
  end
end

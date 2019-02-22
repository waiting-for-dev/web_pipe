module Dry
  module Request
    class Pipe
      attr_reader :steps

      def initialize(steps:)
        @steps = steps
      end

      def call(env)
        conn = Conn.new(env)

        steps.reduce(conn) { |prev_conn, step| step.call(prev_conn) }

        conn.rack_response
      end
    end
  end
end
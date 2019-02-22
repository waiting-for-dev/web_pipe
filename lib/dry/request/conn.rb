module Dry
  module Request
    class Conn
      attr_reader :env
      attr_accessor :resp_body

      def initialize(env)
        @env = env
      end

      def put_response_body(value)
        @resp_body = value
      end

      def rack_response
        [200, {}, [@resp_body]]
      end
    end
  end
end
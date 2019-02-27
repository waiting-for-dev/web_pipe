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
        self
      end

      def rack_response
        [200, {}, [@resp_body]]
      end

      def taint
        dirty = DirtyConn.new(env)
        dirty.resp_body = resp_body
        dirty
      end
    end

    class CleanConn < Conn; end
    class DirtyConn < Conn; end
  end
end
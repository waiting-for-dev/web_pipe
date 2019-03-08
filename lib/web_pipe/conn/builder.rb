require 'rack'
require 'dry/struct'
require 'web_pipe/conn'

module WebPipe
  class Conn < Dry::Struct
    module Builder
      def self.call(env)
        rr = Rack::Request.new(env)
        CleanConn.new(
          request: {
            params: rr.params,
            headers: Hash[env.select { |k, v| k.start_with?('HTTP_') }.map { |k, v| [k[5 .. -1], v] }]
          }
        )
      end
    end
  end
end
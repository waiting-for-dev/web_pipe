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
            headers: extract_headers(env)
          }
        )
      end

      def self.extract_headers(env)
        Hash[
          env.select { |k, v| k.start_with?('HTTP_') }
            .map do |k, v|
              [
                k[5 .. -1].downcase.split('_').map(&:capitalize).join('-'),
                v
              ]
          end
        ]
      end
      private_class_method :extract_headers
    end
  end
end
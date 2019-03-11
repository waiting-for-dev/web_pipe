require 'rack'
require 'dry/struct'
require 'web_pipe/conn'

module WebPipe
  class Conn < Dry::Struct
    # @private
    module Builder
      def self.call(env)
        rr = Rack::Request.new(env)
        CleanConn.new(**{
                        request: {
                          params: rr.params,
                          headers: extract_headers(env),
                          req_method: extract_method(rr),
                          script_name: rr.script_name,
                          path_info: rr.path_info,
                          query_string: rr.query_string,
                          server_name: env['SERVER_NAME'],
                          server_port: rr.port
                        }
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

      def self.extract_method(rr)
        rr.request_method.downcase.to_sym
      end
      private_class_method :extract_method
    end
  end
end
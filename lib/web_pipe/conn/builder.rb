require 'rack'
require 'dry/struct'
require 'web_pipe/conn'
require 'web_pipe/conn/types'

module WebPipe
  class Conn < Dry::Struct
    # @private
    module Builder
      def self.call(env)
        rr = ::Rack::Request.new(env)
        CleanConn.new(**{
                        request: {
                          rack_request: rr,
                          rack_env: env,

                          scheme: rr.scheme.to_sym,
                          req_method: extract_method(rr),
                          host: rr.host,
                          ip: rr.ip,
                          port: rr.port,
                          script_name: rr.script_name,
                          path_info: rr.path_info,
                          query_string: rr.query_string,
                          headers: extract_headers(env),

                          base_url: Types::Request::Unfetched.new(type: :base_url),
                          path: Types::Request::Unfetched.new(type: :path),
                          full_path: Types::Request::Unfetched.new(type: :full_path),
                          url: Types::Request::Unfetched.new(type: :url),
                          params: Types::Request::Unfetched.new(type: :params),
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
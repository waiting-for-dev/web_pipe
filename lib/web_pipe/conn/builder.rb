require 'rack'
require 'dry/struct'
require 'web_pipe/conn'
require 'web_pipe/conn/types'

module WebPipe
  class Conn < Dry::Struct
    # @private
    module Builder
      HEADERS_AS_CGI = %w[CONTENT_TYPE CONTENT_LENGTH]

      def self.call(env)
        rr = ::Rack::Request.new(env)
        CleanConn.new(**{
                        request: {
                          rack_request: rr,
                          rack_env: env,

                          scheme: rr.scheme.to_sym,
                          req_method: rr.request_method.downcase.to_sym,
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
        normalize = -> (key) { key.downcase.split('_').map(&:capitalize).join('-') }
        pair = -> (key, value) { [normalize.(key), value] }
        Hash[
          env.
            select { |k, _v| k.start_with?('HTTP_') }.
            map { |k, v| pair.(k[5 .. -1], v) }.
            concat(
              env.
                select { |k, _v| HEADERS_AS_CGI.include?(k) }.
                map { |k, v| pair.(k, v) }
            )
        ]
      end
      private_class_method :extract_headers
    end
  end
end
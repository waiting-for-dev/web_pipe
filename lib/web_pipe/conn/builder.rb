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
        CleanConn.new(
          request: rr,
          env: env,

          scheme: rr.scheme.to_sym,
          request_method: rr.request_method.downcase.to_sym,
          host: rr.host,
          ip: rr.ip,
          port: rr.port,
          script_name: rr.script_name,
          path_info: rr.path_info,
          query_string: rr.query_string,

          request_headers: Types::Request::Unfetched.new(type: :headers),

          base_url: Types::Request::Unfetched.new(type: :base_url),
          path: Types::Request::Unfetched.new(type: :path),
          full_path: Types::Request::Unfetched.new(type: :full_path),
          url: Types::Request::Unfetched.new(type: :url),
          params: Types::Request::Unfetched.new(type: :params),

          request_body: Types::Request::Unfetched.new(type: :body),
          
          status: Types::Response::Unset.new(type: :status),
          
          cookies: Types::Request::Unfetched.new(type: :cookies),
        )
      end
    end
  end
end
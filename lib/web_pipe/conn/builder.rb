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
        CleanConn.new(request: {
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

                        headers: Types::Request::Unfetched.new(type: :headers),

                        base_url: Types::Request::Unfetched.new(type: :base_url),
                        path: Types::Request::Unfetched.new(type: :path),
                        full_path: Types::Request::Unfetched.new(type: :full_path),
                        url: Types::Request::Unfetched.new(type: :url),
                        params: Types::Request::Unfetched.new(type: :params),

                        body: Types::Request::Unfetched.new(type: :body),
                        
                        cookies: Types::Request::Unfetched.new(type: :cookies)
                      },
                      response: {
                        status: Types::Response::Unset.new(type: :status)
                      }
                     )
      end
    end
  end
end
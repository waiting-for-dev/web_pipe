require 'rack'
require 'web_pipe/conn/struct'
require 'web_pipe/conn/types'

module WebPipe
  module Conn
    # @private
    module Builder
      def self.call(env)
        rr = ::Rack::Request.new(env)
        Clean.new(
          request: rr,
          env: env,
          session: Types::Unfetched.new(type: :session),

          scheme: rr.scheme.to_sym,
          request_method: rr.request_method.downcase.to_sym,
          host: rr.host,
          ip: rr.ip,
          port: rr.port,
          script_name: rr.script_name,
          path_info: rr.path_info,
          query_string: rr.query_string,

          request_headers: Types::Unfetched.new(type: :headers),

          request_body: Types::Unfetched.new(type: :body),
          
          status: Types::Unset.new(type: :status)
        )
      end
    end
  end
end
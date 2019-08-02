require 'rack'
require 'web_pipe/conn'
require 'web_pipe/conn_support/headers'

module WebPipe
  module ConnSupport
    # Helper module to build a {Conn} from a rack's env.
    #
    # It always return a {Conn::Ongoing} subclass.
    #
    # @api private
    module Builder
      # @param env [Types::Env] Rack's env
      #
      # @return [Conn::Ongoing]
      def self.call(env)
        rr = ::Rack::Request.new(env)
        Conn::Ongoing.new(
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
          request_body: rr.body,
          request_headers: Headers.extract(env)
        )
      end
    end
  end
end
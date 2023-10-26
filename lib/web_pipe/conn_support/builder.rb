# frozen_string_literal: true

require "rack"
require "web_pipe/conn"
require "web_pipe/conn_support/headers"

module WebPipe
  module ConnSupport
    # @api private
    module Builder
      # rubocop:disable Metrics/MethodLength
      def self.call(env)
        rr = Rack::Request.new(env)
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
      # rubocop:enable Metrics/MethodLength
    end
  end
end

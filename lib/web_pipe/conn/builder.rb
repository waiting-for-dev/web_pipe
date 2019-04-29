require 'rack'
require 'web_pipe/conn/struct'
require 'web_pipe/conn/types'

module WebPipe
  module Conn
    # @private
    module Builder
      # Headers which come as plain CGI variables (without the `HTTP_`
      # prefixed) from the rack server.
      #
      # @private
      HEADERS_AS_CGI = %w[CONTENT_TYPE CONTENT_LENGTH].freeze

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
          request_body: rr.body,
          request_headers: extract_headers(env),

          status: Types::Unset.new(type: :status)
        )
      end

      def self.extract_headers(env)
        Hash[
          env.
            select { |k, _v| k.start_with?('HTTP_') }.
            map { |k, v| header_pair(k[5 .. -1], v) }.
            concat(
              env.
                select { |k, _v| HEADERS_AS_CGI.include?(k) }.
                map { |k, v| header_pair(k, v) }
            )
        ]
      end

      def self.header_pair(key, value)
        [normalize_header_key(key), value]
      end

      def self.normalize_header_key(key)
        key.downcase.gsub('_', '-').split('-').map(&:capitalize).join('-')
      end
    end
  end
end
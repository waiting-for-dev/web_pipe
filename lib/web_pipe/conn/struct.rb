require 'dry/struct'
require 'web_pipe/conn/types'
require 'web_pipe/conn/builder'

module WebPipe
  module Conn
    class Struct < Dry::Struct
      ID = -> (x) { x }

      HEADERS_AS_CGI = %w[CONTENT_TYPE CONTENT_LENGTH]

      # RACK
      attribute :env, Types::Env
      attribute :request, Types::Requesting

      # REQUEST
      attribute :scheme, Types::Scheme
      attribute :request_method, Types::Method
      attribute :host, Types::Host
      attribute :ip, Types::Ip
      attribute :port, Types::Port
      attribute :script_name, Types::ScriptName
      attribute :path_info, Types::PathInfo
      attribute :query_string, Types::QueryString
      # Headers
      attribute :request_headers, Types::RequestHeaders
      # URL redundancy
      attribute :base_url, Types::BaseUrl
      attribute :path, Types::Path
      attribute :full_path, Types::FullPath
      attribute :url, Types::Url
      attribute :params, Types::Params
      # Body
      attribute :request_body, Types::RequestBody

      # RESPONSE
      attribute :status, Types::Status
      attribute :response_body, Types::ResponseBody
      attribute :response_headers, Types::ResponseHeaders

      # SESSION
      attribute :session, Types::Session

      # BAG
      attribute :bag, Types::Bag

      def fetch_redundants
        new(
          base_url: request.base_url,
          path: request.path,
          full_path: request.fullpath,
          url: request.url,
          params: request.params
        )
      end

      def fetch_request_body(parser = ID)
        new(
          request_body: parser.(request.body)
        )
      end

      def fetch_request_headers
        new(
          request_headers: extract_headers(env)
        )
      end

      def set_status(code)
        new(
          status: code
        )
      end

      def set_response_body(content)
        new(
          response_body: content.is_a?(Array) ? content : [content]
        )
      end

      def add_response_header(key, value)
        new(
          response_headers: Hash[
            response_headers.to_a.append(header_pair(key, value))
          ]
        )
      end

      def delete_response_header(key)
        new(
          response_headers: response_headers.reject do |k, _v|
            normalize_header_key(key) == k
          end
        )
      end

      def fetch_session
        new(
          session: request.session
        )
      end

      def rack_response
        [
          status,
          response_headers,
          response_body
        ]
      end

      def taint
        Dirty.new(attributes)
      end

      private

      def extract_headers(env)
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

      def header_pair(key, value)
        [normalize_header_key(key), value]
      end

      def normalize_header_key(key)
        key.downcase.gsub('_', '-').split('-').map(&:capitalize).join('-')
      end
    end

    class Clean < Struct; end
    class Dirty < Struct; end
  end
end
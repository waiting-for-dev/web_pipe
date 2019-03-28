require 'dry/struct'
require 'web_pipe/conn/types'
require 'web_pipe/conn/builder'

module WebPipe
  class Conn < Dry::Struct
    attr_accessor :resp_body

    def set_status(code)
      new(response: response.new(status: code))
    end

    def set_response_body(content)
      new(response: response.new(
            body: content.is_a?(Array) ? content : [content]
          ))
    end

    def add_response_header(key, value)
      new(response: response.new(
            headers: Hash[response.headers.to_a.append(request.send(:header_pair, key, value))]
          ))
    end

    def delete_response_header(key)
      new(response: response.new(
            headers: response.headers.reject { |k, _v| request.send(:normalize_header_key, key) == k }
          ))
    end

    attribute :response do
      attribute :status, Types::Response::Status
      attribute :body, Types::Response::Body
      attribute :headers, Types::Response::Headers
    end

    attribute :request do
      ID = -> (x) { x }

      HEADERS_AS_CGI = %w[CONTENT_TYPE CONTENT_LENGTH]

      # Rack
      attribute :rack_env, Types::Request::RackEnv
      attribute :rack_request, Types::Request::RackRequest
      # Request
      attribute :scheme, Types::Request::Scheme
      attribute :req_method, Types::Request::Method
      attribute :host, Types::Request::Host
      attribute :ip, Types::Request::Ip
      attribute :port, Types::Request::Port
      attribute :script_name, Types::Request::ScriptName
      attribute :path_info, Types::Request::PathInfo
      attribute :query_string, Types::Request::QueryString
      # Headers
      attribute :headers, Types::Request::Headers
      # URL redundancy
      attribute :base_url, Types::Request::BaseUrl
      attribute :path, Types::Request::Path
      attribute :full_path, Types::Request::FullPath
      attribute :url, Types::Request::Url
      attribute :params, Types::Request::Params
      # Body
      attribute :body, Types::Request::Body
      # Cookies
      attribute :cookies, Types::Request::Cookies

      def fetch_redundants
        new_parent(
          base_url: rack_request.base_url,
          path: rack_request.path,
          full_path: rack_request.fullpath,
          url: rack_request.url,
          params: rack_request.params
        )
      end

      def fetch_body(parser = ID)
        new_parent(
          body: parser.(rack_request.body)
        )
      end

      def fetch_headers
        new_parent(
          headers: extract_headers(rack_env)
        )
      end

      def fetch_cookies
        new_parent(
          cookies: rack_request.session
        )
      end

      private

      def new_parent(attrs)
        Builder.call(rack_env).new(request: new(attrs))
      end

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
        key.downcase.split('_').map(&:capitalize).join('-')
      end
    end

    def put_response_body(value)
      @resp_body = value
      self
    end

    def rack_response
      [200, {}, [@resp_body]]
    end

    def taint
      dirty = DirtyConn.new(attributes)
      dirty.resp_body = resp_body
      dirty
    end
  end

  class CleanConn < Conn; end
  class DirtyConn < Conn; end
end
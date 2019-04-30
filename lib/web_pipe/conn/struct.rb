require 'dry/struct'
require 'web_pipe/conn/types'
require 'web_pipe/conn/headers'

module WebPipe
  module Conn
    class Struct < Dry::Struct
      # RACK
      #
      # @!attribute [r] env
      #
      # @return [Types::Env] Rack env hash.
      #
      # @see https://www.rubydoc.info/github/rack/rack/file/SPEC
      attribute :env, Types::Env

      # @!attribute [r] request
      #
      # @return [Types::Request] Rack request.
      #
      # @see https://www.rubydoc.info/github/rack/rack/Rack/Request
      attribute :request, Types::Request

      # @!attribute [r] session
      #
      # @return [Types::Session] Rack session.
      #
      # @see https://www.rubydoc.info/github/rack/rack/Rack/Session
      attribute :session, Types::Session

      # REQUEST
      #
      # @!attribute [r] scheme
      #
      # @return [Types::Scheme] Scheme of the request.
      #
      # @example
      #   :http
      attribute :scheme, Types::Scheme

      # @!attribute [r] request_method
      #
      # @return [Types::Method] Method of the request.
      #
      # It is not called `:method` in order not to collide with
      # {Object#method}.
      #
      # @example
      #   :get
      attribute :request_method, Types::Method

      # @!attribute [r] host
      #
      # @return [Types::Host] Host being requested.
      #
      # @example
      #   'www.example.org'
      attribute :host, Types::Host

      # @!attribute [r] ip
      #
      # @return [Types::IP] IP being requested.
      #
      # @example
      #   '192.168.1.1'
      attribute :ip, Types::Ip

      # @!attribute [r] port
      #
      # @return [Types::Port] Port in which the request is made.
      #
      # @example
      #   443
      attribute :port, Types::Port

      # @!attribute [r] script_name
      #
      # @return [Types::ScriptName] Script name in the URL, or the
      # empty string if none.
      #
      # @example
      #   'index.rb'
      attribute :script_name, Types::ScriptName

      # @!attribute [r] path_info
      #
      # @return [Types::PathInfo] Besides {#script_name}, the
      # remainder path of the URL or the empty string if none. It is,
      # at least, `/` when `#script_name` is empty.
      #
      # This doesn't include the {#query_string}.
      #
      # @example
      #   '/foo/bar'.
      attribute :path_info, Types::PathInfo

      # @!attribute [r] query_string
      #
      # @return [Types::QueryString] Query String of the URL
      # (everything after `?` , or the empty string if none.
      #
      # @example
      #   'foo=bar&bar=foo'
      attribute :query_string, Types::QueryString

      # @!attribute [r] request_body
      #
      # @return [Types::RequestBody] Body sent by the request.
      #
      # @example
      #   '{ resource: "foo" }'
      attribute :request_body, Types::RequestBody

      # @!attribute [r] request_headers
      #
      # @return [Types::Headers] Hash of request headers.
      #
      # As per RFC2616, headers names are case insensitive. Here, they
      # are normalized to PascalCase acting on dashes ('-').
      #
      # Notice that when a rack server maps headers to CGI-like
      # variables, both dashes and underscores (`_`) are treated as
      # dashes. Here, they always remain as dashes.
      #
      # @see https://www.w3.org/Protocols/rfc2616/rfc2616-sec4.html#sec4.2
      #
      # @example
      #   { 'Accept-Charset' => 'utf8' }
      attribute :request_headers, Types::Headers

      # @!attribute [r] status
      #
      # @return [Types::Status] Status sent by the response.
      #
      # @example
      #   200
      attribute :status, Types::Status

      # @!attribute [r] response_body
      #
      # @return [Types::ResponseBody] Body sent by the response.
      #
      # @example
      #    ['<html></html>']
      attribute :response_body, Types::ResponseBody

      # @!attribute [r] response_headers
      #
      # @return [Types::Headers] Response headers.
      #
      # @see #request_headers for normalization details
      #
      # @example
      #
      #   { 'Content-Type' => 'text/html' }
      attribute :response_headers, Types::Headers

      # @!attribute [r] bag
      #
      # @return [Types::Bag] Hash where anything can be stored.
      #
      # This can be used to store anything that is needed to be
      # consumed downstream in a pipe of operations action on and
      # returning {Conn::Struct}.
      attribute :bag, Types::Bag

      # Base part of the URL.
      #
      # This is {#scheme} and {#host}, adding {#port} unless it is the
      # default one for the scheme.
      #
      # @return [Types::BaseUrl]
      #
      # @example
      #   'https://example.org'
      #   'http://example.org:8000'
      def base_url
        request.base_url
      end

      # URL path.
      #
      # This is {#script_name} and {#path_info}.
      #
      # @return [Types::Path]
      #
      # @example
      #   'index.rb/users'
      def path
        request.path
      end

      # URL full path.
      #
      # This is {#path} with {#query_string} if present.
      #
      # @return [Types::FullPath]
      #
      # @example
      #   '/users?id=1'
      def full_path
        request.fullpath
      end

      # Request URL.
      #
      # This is the same as {#base_url} plus {#full_path}.
      #
      # @return [Types::Url]
      #
      # @example
      #   'http://www.example.org:8000/users?id=1'
      def url
        request.url
      end

      # GET and POST params merged in a hash.
      #
      # @return [Types::Params]
      #
      # @example
      #   { 'id' => 1, 'name' => 'Joe' }
      def params
        request.params
      end

      # Sets response status code.
      #
      # @param code [Types::StatusCode]
      #
      # @return {Struct}
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
          response_headers: Headers.add(response_headers, key, value)
        )
      end

      def delete_response_header(key)
        new(
          response_headers: Headers.delete(response_headers, key)
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
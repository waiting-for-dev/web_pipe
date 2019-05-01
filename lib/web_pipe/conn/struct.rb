require 'dry/struct'
require 'web_pipe/conn/types'
require 'web_pipe/conn/errors'
require 'web_pipe/conn/headers'

module WebPipe
  module Conn
    # Struct and methods about web request and response data.
    #
    # It is meant to contain all the data coming from a web request
    # along with all the data needed to build a web response. It can
    # be built with {Conn::Builder}.
    #
    # Besides data fetching methods and {#rack_response), any other
    # method returns a fresh new instance of it, so it is thought to
    # be used in an immutable way and to allow chaining of method
    # calls.
    #
    # There are two subclasses (two types) for this:
    # {Conn::Struct::Clean} and {Conn::Struct::Dirty}. `Conn::Builder`
    # constructs a `Clean` struct, while {#taint} copies the data to a
    # `Dirty` instance. The intention of this is to halt operations on
    # the web request/response cycle one a `Dirty` instance is
    # detected.
    #
    # @example
    #   WebPipe::Conn::Builder.call(env).
    #     set_status(404).
    #     add_response_header('Content-Type', 'text/plain').
    #     set_response_body('Not found').
    #     taint
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
      # @return [Types::Bag] Hash where anything can be stored. Keys
      # must be symbols.
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
      # @return {Conn::Struct}
      def set_status(code)
        new(
          status: code
        )
      end

      # Sets response body.
      #
      # As per rack specification, the response body must respond to
      # `#each`. Here, when given `content` responds to `:each` it is
      # set as it is as the new response body. Otherwise, what is set
      # is a one item array of it.
      #
      # @param content [#each, String]
      #
      # @return {Conn::Struct}
      #
      # @see https://www.rubydoc.info/github/rack/rack/master/file/SPEC#label-The+Body
      def set_response_body(content)
        new(
          response_body: content.respond_to?(:each) ? content : [content]
        )
      end

      # Adds given pair to response headers.
      #
      # `key` is normalized.
      #
      # @param key [String]
      # @param value [String]
      #
      # @return {Conn::Struct}
      #
      # @see Headers.normalize_key
      def add_response_header(key, value)
        new(
          response_headers: Headers.add(response_headers, key, value)
        )
      end

      # Deletes pair with given key from response headers.
      #
      # It accepts a non normalized key.
      #
      # @param key [String]
      #
      # @return {Conn::Struct}
      #
      # @see Headers.normalize_key
      def delete_response_header(key)
        new(
          response_headers: Headers.delete(response_headers, key)
        )
      end

      # Reads an item from {#bag}.
      #
      # @param key [Symbol]
      #
      # @return [Object]
      #
      # @raise KeyNotFoundInBagError when key is not registered in the
      # bag.
      def fetch(key)
        bag.fetch(key) { raise KeyNotFoundInBagError.new(key) }
      end

      # Writes an item to the {#bag}.
      #
      # If it already exists, it is overwritten.
      #
      # @param key [Symbol]
      # @param value [Object]
      #
      # @return [Conn::Struct]
      def put(key, value)
        new(
          bag: bag.merge(key => value)
        )
      end

      # Builds response in the way rack expects.
      #
      # It is useful to finish a rack application built with a
      # {Conn::Struct}. After every desired operation has been done,
      # this method has to be called before giving control back to
      # rack.
      #
      # @return
      #   [Array<Types::StatusCode, Types::Headers, Types::ResponseBody>]
      def rack_response
        [
          status,
          response_headers,
          response_body
        ]
      end

      # Copies all the data to a {Dirty} instance and
      # returns it.
      #
      # @return [Dirty]
      def taint
        Dirty.new(attributes)
      end

      # Type of {Conn::Struct} representing an ongoing request/response
      # cycle.
      class Clean < Struct; end

      # Type of {Conn::Struct} representing a halted request/response
      # cycle.
      class Dirty < Struct; end
    end
  end
end
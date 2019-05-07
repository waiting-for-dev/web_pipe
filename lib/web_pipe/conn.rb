require 'dry/struct'
require 'web_pipe/conn_support/types'
require 'web_pipe/conn_support/errors'
require 'web_pipe/conn_support/headers'

module WebPipe
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
  # {Conn::Clean} and {Conn::Dirty}. `Conn::Builder`
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
  class Conn < Dry::Struct
    include ConnSupport::Types

    # RACK
    #
    # @!attribute [r] env
    #
    # @return [Env[]] Rack env hash.
    #
    # @see https://www.rubydoc.info/github/rack/rack/file/SPEC
    attribute :env, Env

    # @!attribute [r] request
    #
    # @return [Request[]] Rack request.
    #
    # @see https://www.rubydoc.info/github/rack/rack/Rack/Request
    attribute :request, Request

    # REQUEST
    #
    # @!attribute [r] scheme
    #
    # @return [Scheme[]] Scheme of the request.
    #
    # @example
    #   :http
    attribute :scheme, Scheme

    # @!attribute [r] request_method
    #
    # @return [Method[]] Method of the request.
    #
    # It is not called `:method` in order not to collide with
    # {Object#method}.
    #
    # @example
    #   :get
    attribute :request_method, Method

    # @!attribute [r] host
    #
    # @return [Host[]] Host being requested.
    #
    # @example
    #   'www.example.org'
    attribute :host, Host

    # @!attribute [r] ip
    #
    # @return [IP[]] IP being requested.
    #
    # @example
    #   '192.168.1.1'
    attribute :ip, Ip

    # @!attribute [r] port
    #
    # @return [Port[]] Port in which the request is made.
    #
    # @example
    #   443
    attribute :port, Port

    # @!attribute [r] script_name
    #
    # @return [ScriptName[]] Script name in the URL, or the
    # empty string if none.
    #
    # @example
    #   'index.rb'
    attribute :script_name, ScriptName

    # @!attribute [r] path_info
    #
    # @return [PathInfo[]] Besides {#script_name}, the
    # remainder path of the URL or the empty string if none. It is,
    # at least, `/` when `#script_name` is empty.
    #
    # This doesn't include the {#query_string}.
    #
    # @example
    #   '/foo/bar'.
    attribute :path_info, PathInfo

    # @!attribute [r] query_string
    #
    # @return [QueryString[]] Query String of the URL
    # (everything after `?` , or the empty string if none.
    #
    # @example
    #   'foo=bar&bar=foo'
    attribute :query_string, QueryString

    # @!attribute [r] request_body
    #
    # @return [RequestBody[]] Body sent by the request.
    #
    # @example
    #   '{ resource: "foo" }'
    attribute :request_body, RequestBody

    # @!attribute [r] request_headers
    #
    # @return [Headers[]] Hash of request headers.
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
    attribute :request_headers, Headers

    # @!attribute [r] status
    #
    # @return [Status[]] Status sent by the response.
    #
    # @example
    #   200
    attribute :status, Status

    # @!attribute [r] response_body
    #
    # @return [ResponseBody[]] Body sent by the response.
    #
    # @example
    #    ['<html></html>']
    attribute :response_body, ResponseBody

    # @!attribute [r] response_headers
    #
    # @return [Headers[]] Response headers.
    #
    # @see #request_headers for normalization details
    #
    # @example
    #
    #   { 'Content-Type' => 'text/html' }
    attribute :response_headers, Headers

    # @!attribute [r] bag
    #
    # @return [Bag[]] Hash where anything can be stored. Keys
    # must be symbols.
    #
    # This can be used to store anything that is needed to be
    # consumed downstream in a pipe of operations action on and
    # returning {Conn}.
    attribute :bag, Bag

    # Base part of the URL.
    #
    # This is {#scheme} and {#host}, adding {#port} unless it is the
    # default one for the scheme.
    #
    # @return [BaseUrl]
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
    # @return [Path]
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
    # @return [FullPath]
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
    # @return [Url]
    #
    # @example
    #   'http://www.example.org:8000/users?id=1'
    def url
      request.url
    end

    # GET and POST params merged in a hash.
    #
    # @return [Params]
    #
    # @example
    #   { 'id' => 1, 'name' => 'Joe' }
    def params
      request.params
    end

    # Sets response status code.
    #
    # @param code [StatusCode]
    #
    # @return {Conn}
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
    # @return {Conn}
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
    # @return {Conn}
    #
    # @see Headers.normalize_key
    def add_response_header(key, value)
      new(
        response_headers: ConnSupport::Headers.add(
          response_headers, key, value
        )
      )
    end

    # Deletes pair with given key from response headers.
    #
    # It accepts a non normalized key.
    #
    # @param key [String]
    #
    # @return {Conn}
    #
    # @see Headers.normalize_key
    def delete_response_header(key)
      new(
        response_headers: ConnSupport::Headers.delete(
          response_headers, key
        )
      )
    end

    # Reads an item from {#bag}.
    #
    # @param key [Symbol]
    #
    # @return [Object]
    #
    # @raise ConnSupport::KeyNotFoundInBagError when key is not
    # registered in the bag.
    def fetch(key)
      bag.fetch(key) { raise ConnSupport::KeyNotFoundInBagError.new(key) }
    end

    # Writes an item to the {#bag}.
    #
    # If it already exists, it is overwritten.
    #
    # @param key [Symbol]
    # @param value [Object]
    #
    # @return [Conn]
    def put(key, value)
      new(
        bag: bag.merge(key => value)
      )
    end

    # Builds response in the way rack expects.
    #
    # It is useful to finish a rack application built with a
    # {Conn}. After every desired operation has been done,
    # this method has to be called before giving control back to
    # rack.
    #
    # @return
    #   [Array<StatusCode, Headers, ResponseBody>]
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

    # Type of {Conn} representing an ongoing request/response
    # cycle.
    class Clean < Conn; end

    # Type of {Conn} representing a halted request/response
    # cycle.
    class Dirty < Conn; end
  end
end
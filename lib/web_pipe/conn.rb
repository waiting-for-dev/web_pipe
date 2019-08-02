require 'dry/struct'
require 'web_pipe/types'
require 'web_pipe/conn_support/types'
require 'web_pipe/conn_support/errors'
require 'web_pipe/conn_support/headers'

module WebPipe
  # Struct and methods about web request and response data.
  #
  # It is meant to contain all the data coming from a web request
  # along with all the data needed to build a web response. It can
  # be built with {ConnSupport::Builder}.
  #
  # Besides data fetching methods and {#rack_response}, any other
  # method returns a fresh new instance of it, so it is thought to
  # be used in an immutable way and to allow chaining of method
  # calls.
  #
  # There are two subclasses (two types) for this:
  # {Conn::Ongoing} and {Conn::Halted}. {ConnSupport::Builder} constructs
  # a {Conn::Ongoing} struct, while {#halt} copies the data to a
  # {Conn::Halted} instance. The intention of this is to halt
  # operations on the web request/response cycle one a {Conn::Halted}
  # instance is detected.
  #
  # @example
  #   WebPipe::ConnSupport::Builder.call(env).
  #     set_status(404).
  #     add_response_header('Content-Type', 'text/plain').
  #     set_response_body('Not found').
  #     halt
  class Conn < Dry::Struct
    include ConnSupport::Types

    # @!attribute [r] env
    #
    # Rack env hash.
    #
    # @return [Env[]]
    #
    # @see https://www.rubydoc.info/github/rack/rack/file/SPEC
    attribute :env, Env

    # @!attribute [r] request
    #
    # Rack request.
    #
    # @return [Request[]]
    #
    # @see https://www.rubydoc.info/github/rack/rack/Rack/Request
    attribute :request, Request

    # @!attribute [r] scheme
    #
    # Scheme of the request.
    #
    # @return [Scheme[]]
    #
    # @example
    #   :http
    attribute :scheme, Scheme

    # @!attribute [r] request_method
    #
    # Method of the request.
    #
    # It is not called `:method` in order not to collide with
    # {Object#method}.
    #
    # @return [Method[]]
    #
    # @example
    #   :get
    attribute :request_method, Method

    # @!attribute [r] host
    #
    # Host being requested.
    #
    # @return [Host[]]
    #
    # @example
    #   'www.example.org'
    attribute :host, Host

    # @!attribute [r] ip
    #
    # IP being requested.
    #
    # @return [IP[]]
    #
    # @example
    #   '192.168.1.1'
    attribute :ip, Ip

    # @!attribute [r] port
    #
    # Port in which the request is made.
    #
    # @return [Port[]]
    #
    # @example
    #   443
    attribute :port, Port

    # @!attribute [r] script_name
    #
    # Script name in the URL, or the empty string if none.
    #
    # @return [ScriptName[]]
    #
    # @example
    #   'index.rb'
    attribute :script_name, ScriptName

    # @!attribute [r] path_info
    #
    # Besides {#script_name}, the remainder path of the URL or the
    # empty string if none. It is, at least, `/` when `#script_name`
    # is empty.
    #
    # This doesn't include the {#query_string}.
    #
    # @return [PathInfo[]]
    #
    # @example
    #   '/foo/bar'.
    attribute :path_info, PathInfo

    # @!attribute [r] query_string
    #
    # Query String of the URL (everything after `?` , or the empty
    # string if none).
    #
    # @return [QueryString[]]
    #
    # @example
    #   'foo=bar&bar=foo'
    attribute :query_string, QueryString

    # @!attribute [r] request_body
    #
    # Body sent by the request.
    #
    # @return [RequestBody[]]
    #
    # @example
    #   '{ resource: "foo" }'
    attribute :request_body, RequestBody

    # @!attribute [r] request_headers
    #
    # Hash of request headers.
    #
    # As per RFC2616, headers names are case insensitive. Here, they
    # are normalized to PascalCase acting on dashes ('-').
    #
    # Notice that when a rack server maps headers to CGI-like
    # variables, both dashes and underscores (`_`) are treated as
    # dashes. Here, they always remain as dashes.
    #
    # @return [Headers[]]
    #
    # @see https://www.w3.org/Protocols/rfc2616/rfc2616-sec4.html#sec4.2
    #
    # @example
    #   { 'Accept-Charset' => 'utf8' }
    attribute :request_headers, Headers

    # @!attribute [r] status
    #
    # Status sent by the response.
    #
    # @return [Status[]]
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
    # Response headers.
    #
    # @see #request_headers for normalization details
    #
    # @return [Headers[]]
    #
    # @example
    #
    #   { 'Content-Type' => 'text/html' }
    attribute :response_headers, Headers

    # @!attribute [r] bag
    #
    # Hash where anything can be stored. Keys
    # must be symbols.
    #
    # This can be used to store anything that is needed to be
    # consumed downstream in a pipe of operations action on and
    # returning {Conn}.
    #
    # @return [Bag[]]
    attribute :bag, Bag

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
    # @see ConnSupport::Headers.normalize_key
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
    # @see ConnSupport::Headers.normalize_key
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
    def fetch(key, default = Types::Undefined)
      return bag.fetch(key, default) unless default == Types::Undefined

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
    def add(key, value)
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
    #
    # @api private
    def rack_response
      [
        status,
        response_headers,
        response_body
      ]
    end

    # Copies all the data to a {Halted} instance and
    # returns it.
    #
    # @return [Halted]
    def halt
      Halted.new(attributes)
    end

    # Returns whether the instance is {Halted}.
    #
    # @return [Bool]
    def halted?
      is_a?(Halted)
    end

    # Type of {Conn} representing an ongoing request/response
    # cycle.
    class Ongoing < Conn; end

    # Type of {Conn} representing a halted request/response
    # cycle.
    class Halted < Conn; end
  end
end
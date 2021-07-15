# frozen_string_literal: true

require 'web_pipe'
require 'rack/utils'

# :nodoc:
module WebPipe
  # Extension to help dealing with request and response cookies.
  #
  # This extension helps with the addition of the `Set-Cookie` header
  # to the response, which is the way the server has to instruct the
  # browser to keep a cookie. A cookie can be added with the
  # {#set_cookie} method, while it can be marked for deletion with
  # {#delete_cookie}. Remember that marking a cookie for deletion just
  # means adding the same cookie name with an expiration time in the
  # past.
  #
  # Besides, it also adds a {#request_cookies} method to get the
  # cookies in the request.
  #
  # @example
  #  require 'web_pipe'
  #
  #  WebPipe.load_extensions(:cookies)
  #
  #  class SetCookie
  #    include WebPipe
  #
  #    plug :set_cookie, ->(conn) { conn.set_cookie('foo', 'bar', path: '/') }
  #  end
  #
  #  class DeleteCookie
  #    include WebPipe
  #
  #    plug :delete_cookie, ->(conn) { conn.delete_cookie('foo', path: '/') }
  #  end
  module Cookies
    # Valid options for {#set_cookie}.
    SET_COOKIE_OPTIONS = Types::Strict::Hash.schema(
      domain?: Types::Strict::String.optional,
      path?: Types::Strict::String.optional,
      max_age?: Types::Strict::Integer.optional,
      expires?: Types::Strict::Time.optional,
      secure?: Types::Strict::Bool.optional,
      http_only?: Types::Strict::Bool.optional,
      same_site?: Types::Strict::Symbol.enum(:none, :lax, :strict).optional
    )

    # Valid options for {#delete_cookie}.
    DELETE_COOKIE_OPTIONS = Types::Strict::Hash.schema(
      domain?: Types::Strict::String.optional,
      path?: Types::Strict::String.optional
    )

    # @return [Hash]
    def request_cookies
      request.cookies
    end

    # @param key [String]
    # @param value [String]
    # @param opts [SET_COOKIE_OPTIONS[]]
    def set_cookie(key, value, opts = Types::EMPTY_HASH)
      Rack::Utils.set_cookie_header!(
        response_headers,
        key,
        { value: value }.merge(SET_COOKIE_OPTIONS[opts])
      )
      self
    end

    # @param key [String]
    # @param opts [DELETE_COOKIE_OPTIONS[]]
    def delete_cookie(key, opts = Types::EMPTY_HASH)
      Rack::Utils.delete_cookie_header!(
        response_headers,
        key,
        DELETE_COOKIE_OPTIONS[opts]
      )
      self
    end
  end

  Conn.include(Cookies)
end

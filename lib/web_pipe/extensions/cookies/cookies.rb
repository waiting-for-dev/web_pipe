# frozen_string_literal: true

require "rack/utils"

# :nodoc:
module WebPipe
  # See the docs for the extension linked from the README.
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

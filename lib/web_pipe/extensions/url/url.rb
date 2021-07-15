# frozen_string_literal: true

# :nodoc:
module WebPipe
  # Adds helper methods related to the request URL.
  #
  # This methods are in fact redundant with the information already
  # present in {Conn} struct but, of course, they are very useful.
  module Url
    # Base part of the URL.
    #
    # This is {#scheme} and {#host}, adding {#port} unless it is the
    # default one for the scheme.
    #
    # @return [String]
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
    # @return [String]
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
    # @return [String]
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
    # @return [String]
    #
    # @example
    #   'http://www.example.org:8000/users?id=1'
    def url
      request.url
    end
  end

  Conn.include(Url)
end

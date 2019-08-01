module WebPipe
  # Adds helper methods related to the request URL.
  #
  # This methods are in fact redundant with the information already
  # present in {Conn} struct but, of course, they are very useful.
  module Url
    # Env's key used to retrieve params set by the router.
    #
    # @see #router_params
    ROUTER_PARAMS_KEY = 'router.params'

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

    # *Params* in rack env's 'router.params' key.
    #
    # Routers used to map routes to applications build with
    # {WebPipe} have the option to introduce extra params through
    # setting env's 'router.params' key. These parameters will be
    # merged with GET and POST ones when calling {#params}.
    #
    # This kind of functionality is usually implemented from the
    # router side allowing the addition of variables in the route
    # definition, e.g.:
    #
    # @example
    #   /user/:id/update
    #
    # @return [Hash]
    def router_params
      env.fetch(ROUTER_PARAMS_KEY, Types::EMPTY_HASH)
    end

    # GET, POST and {#router_params} merged in a hash.
    #
    # @return [Params]
    #
    # @example
    #   { 'id' => '1', 'name' => 'Joe' }
    #
    # @return Hash
    def params
      request.params.merge(router_params)
    end
  end

  Conn.include(Url)
end
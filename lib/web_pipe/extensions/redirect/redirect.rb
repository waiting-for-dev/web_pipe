require 'web_pipe/types'

module WebPipe
  # Helper method to create redirect responses.
  #
  # This extensions adds a {#redirect} method to {Conn} which helps
  # setting the `Location` header and the status code needed to
  # instruct the browser to perform a redirect. By default, `302`
  # status code is used.
  #
  # @example
  #  require 'web_pipe'
  #
  #  WebPipe.load_extensions(:redirect)
  #
  #  class MyApp
  #    include WebPipe
  #
  #    plug(:redirect) do |conn|
  #      conn.redirect('/', 301)
  #    end
  #  end
  module Redirect
    # Location header
    LOCATION_HEADER = 'Location'

    # Valid type for a redirect status code
    RedirectCode = Types::Strict::Integer.constrained(gteq: 300, lteq: 399)
    
    # @param path [String]
    # @param code [Integer]
    def redirect(path, code = 302)
      add_response_header(LOCATION_HEADER, path).
        set_status(RedirectCode[code])
    end
  end

  Conn.include(Redirect)
end
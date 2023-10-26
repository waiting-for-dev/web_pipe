# frozen_string_literal: true

require "web_pipe/types"

# :nodoc:
module WebPipe
  # See the docs for the extension linked from the README.
  module Redirect
    # Location header
    LOCATION_HEADER = "Location"

    # Valid type for a redirect status code
    RedirectCode = Types::Strict::Integer.constrained(gteq: 300, lteq: 399)

    # @param location [String]
    # @param code [Integer]
    def redirect(location, code = 302)
      add_response_header(LOCATION_HEADER, location)
        .set_status(RedirectCode[code])
    end
  end

  Conn.include(Redirect)
end

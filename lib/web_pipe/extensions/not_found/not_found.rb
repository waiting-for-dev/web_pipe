# frozen_string_literal: true

# :nodoc:
module WebPipe
  # See the docs for the extension linked from the README.
  module NotFound
    # @api private
    RESPONSE_BODY_STEP_CONFIG_KEY = :not_found_body_step

    # Generates the not-found response
    #
    # @return [WebPipe::Conn::Halted]
    # @see NotFound
    def not_found
      set_status(404)
        .then do |conn|
          response_body_step = conn.fetch_config(RESPONSE_BODY_STEP_CONFIG_KEY,
                                                 ->(c) { c.set_response_body("Not found") })

          response_body_step.(conn)
        end.halt
    end

    Conn.include(NotFound)
  end
end

# frozen_string_literal: true

require 'web_pipe/conn'
require 'web_pipe/conn_support/errors'

# :nodoc:
module WebPipe
  # See the docs for the extension linked from the README.
  module Flash
    RACK_FLASH_KEY = 'x-rack.flash'

    # Returns the flash bag.
    #
    # @return [Rack::Flash::FlashHash]
    #
    # @raises ConnSupport::MissingMiddlewareError when `Rack::Flash`
    # is not being used as middleware
    def flash
      env.fetch(RACK_FLASH_KEY) do
        raise ConnSupport::MissingMiddlewareError.new(
          'flash', 'Rack::Flash', 'https://rubygems.org/gems/rack-flash3'
        )
      end
    end

    # Adds an item to the flash bag to be consumed by next request.
    #
    # @param key [String]
    # @param value [String]
    def add_flash(key, value)
      flash[key] = value
      self
    end

    # Adds an item to the flash bag to be consumed by the same request
    # in process.
    #
    # @param key [String]
    # @param value [String]
    def add_flash_now(key, value)
      flash.now[key] = value
      self
    end
  end

  Conn.include(Flash)
end

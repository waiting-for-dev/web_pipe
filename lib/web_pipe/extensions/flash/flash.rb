# frozen_string_literal: true

require 'web_pipe/conn'
require 'web_pipe/conn_support/errors'

module WebPipe
  # Provides with a tipical flash messages functionality.
  #
  # @example
  #   require 'web_pipe'
  #   require 'rack/session/cookie'
  #   require 'rack-flash'
  #
  #   WebPipe.load_extensions(:flash)
  #   
  #   class MyApp
  #     include WebPipe
  #
  #     use :session, Rack::Session::Cookie, secret: 'secret'
  #     use :flash, Rack::Flash
  #
  #     plug :put_in_flash, ->(conn) { conn.put_flash(:notice, 'Hello world') }
  #     plug :put_in_flash_now, ->(conn) { conn.put_flash_now(:notice_now, 'Hello world now') }
  #   end
  #
  # Usually, you will end up making `conn.flash` available to your view system:
  #
  # @example
  #   <div class="notice"><%= flash[:notice] %></div>
  #
  # For this extension to be used, `Rack::Flash` middleware must be
  # added to the stack (gem name is `rack-flash3`. This middleware in
  # turns depend on `Rack::Session` middleware.
  #
  # This extension is a very simple wrapper around `Rack::Flash` API.
  #
  # @see https://github.com/nakajima/rack-flash
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
                'flash', 'Rack::Flash', 'rack-flash3'
              )
      end
    end

    # Puts an item to the flash bag to be consumed by next request.
    #
    # @param key [String]
    # @param value [String]
    def put_flash(key, value)
      flash[key] = value
      self
    end

    # Puts an item to the flash bag to be consumed by the same request
    # in process.
    #
    # @param key [String]
    # @param value [String]
    def put_flash_now(key, value)
      flash.now[key] = value
      self
    end
  end

  Conn.include(Flash)
end

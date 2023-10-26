# frozen_string_literal: true

require "web_pipe/conn"
require "web_pipe/types"
require "rack"

# :nodoc:
module WebPipe
  # See the docs for the extension linked from the README.
  module Session
    # Type for session keys.
    SESSION_KEY = Types::Strict::String

    # Returns Rack::Session's hash
    #
    # @return [Rack::Session::Abstract::SessionHash]
    def session
      env.fetch(Rack::RACK_SESSION) do
        raise ConnSupport::MissingMiddlewareError.new(
          "session", "Rack::Session", "https://www.rubydoc.info/github/rack/rack/Rack/Session"
        )
      end
    end

    # Fetches given key from the session.
    #
    # @param key [SESSION_KEY[]] Session key to fetch
    # @param default [Any] Default value if key is not found
    # @yieldreturn Default value if key is not found and default is not given
    # @raise KeyError When key is not found and not default nor block are given
    # @return [Any]
    def fetch_session(*args, &block)
      SESSION_KEY[args[0]]
      session.fetch(*args, &block)
    end

    # Adds given key/value pair to the session.
    #
    # @param key [SESSION_KEY[]] Session key
    # @param value [Any] Value
    # @return [Conn]
    def add_session(key, value)
      session[SESSION_KEY[key]] = value
      self
    end

    # Deletes given key form the session.
    #
    # @param key [SESSION_KEY[]] Session key
    # @return [Conn]
    def delete_session(key)
      session.delete(SESSION_KEY[key])
      self
    end

    # Deletes everything from the session.
    #
    # @return [Conn]
    def clear_session
      session.clear
      self
    end
  end

  Conn.include(Session)
end

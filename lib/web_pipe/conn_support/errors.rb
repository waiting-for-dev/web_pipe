# frozen_string_literal: true

module WebPipe
  module ConnSupport
    # Error raised when trying to fetch an entry in {WebPipe::Conn#bag} for an
    # unknown key.
    class KeyNotFoundInBagError < KeyError
      # @param key [Any] Key not found in the bag
      def initialize(key)
        super(
          <<~MSG
            Bag does not contain a key with name +#{key}+.
          MSG
        )
      end
    end

    # Error raised when trying to fetch an entry in {WebPipeConn#config} for an
    # unknown key.
    class KeyNotFoundInConfigError < KeyError
      # @param key [Any] Key not found in config
      def initialize(key)
        super(
          <<~MSG
            Config does not contain a key with name +#{key}+.
          MSG
        )
      end
    end

    # Error raised when trying to use a {WebPipe::Conn} feature which requires a
    # rack middleware that is not present
    class MissingMiddlewareError < RuntimeError
      # @param feature [String] Name of the feature intended to be used
      # @param middleware [String] Name of the missing middleware
      # @param gem [String] Gem name for the middleware
      def initialize(feature, middleware, gem)
        super(
          <<~MSG
            In order to use #{feature} you must use #{middleware} middleware:
            https://rubygems.org/gems/#{gem}
          MSG
        )
      end
    end
  end
end

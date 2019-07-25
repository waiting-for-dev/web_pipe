module WebPipe
  module ConnSupport
    # Error raised when trying to fetch an entry in {Conn}'s bag for
    # an unknown key.
    class KeyNotFoundInBagError < KeyError
      # @param key [Any] Key not found in the bag
      def initialize(key)
        super(
          <<~eos
            Bag does not contain a key with name +#{key}+.
          eos
        )
      end
    end

    # Error raised when trying to use a conn's feature which requires
    # a rack middleware which is not present
    class MissingMiddlewareError < RuntimeError
      # @param feature [String] Name of the feature intended to be used
      # @param middleware [String] Name of the missing middleware
      # @param gem [String] Gem name for the middleware
      def initialize(feature, middleware, gem)
        super(
          <<~eos
            In order to use #{feature} you must use #{middleware} middleware:
            https://rubygems.org/gems/#{gem}
          eos
        )
      end
    end
  end
end
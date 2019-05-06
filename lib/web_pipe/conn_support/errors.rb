module WebPipe
  module ConnSupport
    # Error raised when trying to fetch an entry in {Conn}'s bag for
    # an unknown key.
    class KeyNotFoundInBagError < KeyError
      def initialize(key)
        super(
          <<~eos
            Bag does not contain a key with name +key+.
          eos
        )
      end
    end
  end
end
module WebPipe
  module ConnSupport
    # Helpers to work with headers and its rack's env representation.
    #
    # @api private
    module Headers
      # Headers which come as plain CGI-like variables (without the `HTTP_`
      # prefixed) from the rack server.
      HEADERS_AS_CGI = %w[CONTENT_TYPE CONTENT_LENGTH].freeze

      # Extracts headers from rack's env.
      #
      # Headers are all those pairs which key begins with `HTTP_` plus
      # those detailed in {HEADERS_AS_CGI}.
      # 
      # @param env [Types::Env[]]
      #
      # @return [Types::Headers[]]
      #
      # @see HEADERS_AS_CGI
      # @see .normalize_key
      def self.extract(env)
        Hash[
          env.
            select { |k, _v| k.start_with?('HTTP_') }.
            map { |k, v| pair(k[5 .. -1], v) }.
            concat(
              env.
                select { |k, _v| HEADERS_AS_CGI.include?(k) }.
                map { |k, v| pair(k, v) }
            )
        ]
      end

      # Adds key/value pair to given headers.
      #
      # Key is normalized.
      #
      # @param headers [Type::Headers[]]
      # @param key [String]
      # @param value [String]
      #
      # @return [Type::Headers[]]
      #
      # @see .normalize_key
      def self.add(headers, key, value)
        Hash[
          headers.to_a.push(pair(key, value))
        ]
      end

      # Deletes pair with given key form headers.
      #
      # Accepts a non normalized key.
      #
      # @param headers [Type::Headers[]]
      # @param key [String]
      #
      # @return [Type::Headers[]]
      #
      # @see .normalize_key
      def self.delete(headers, key)
        headers.reject { |k, _v| normalize_key(key) == k }
      end

      # Creates a pair with normalized key and raw value.
      #
      # @param key [String]
      # @param key [String]
      #
      # @return [Array<String>]
      #
      # @see .normalize_key
      def self.pair(key, value)
        [normalize_key(key), value]
      end

      # Normalizes a header key to convention.
      #
      # As per RFC2616, headers names are case insensitive. This
      # function normalizes them to PascalCase acting on dashes ('-').
      #
      # When a rack server maps headers to CGI-like variables, both
      # dashes and underscores (`_`) are treated as dashes. This
      # function substitutes all '-' to '_'.
      #
      # @param key [String]
      #
      # @return [String]
      #
      # @see https://www.w3.org/Protocols/rfc2616/rfc2616-sec4.html#sec4.2
      def self.normalize_key(key)
        key.downcase.gsub('_', '-').split('-').map(&:capitalize).join('-')
      end

      # Returns a new hash with all keys normalized.
      #
      # @see #normalize_key
      def self.normalize(headers)
        headers.transform_keys(&method(:normalize_key))
      end
    end
  end
end
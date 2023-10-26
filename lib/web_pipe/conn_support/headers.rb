# frozen_string_literal: true

module WebPipe
  module ConnSupport
    # @api private
    module Headers
      # Headers which come as plain CGI-like variables (without the `HTTP_`
      # prefixed) from the rack server.
      HEADERS_AS_CGI = %w[CONTENT_TYPE CONTENT_LENGTH].freeze

      # Headers are all those pairs which key begins with `HTTP_` plus
      # those detailed in {HEADERS_AS_CGI}.
      def self.extract(env)
        Hash[
          env
          .select { |k, _v| k.start_with?("HTTP_") }
          .map { |k, v| pair(k[5..], v) }
          .concat(
            env
              .select { |k, _v| HEADERS_AS_CGI.include?(k) }
              .map { |k, v| pair(k, v) }
          )
        ]
      end

      def self.add(headers, key, value)
        Hash[
          headers.to_a.push(pair(key, value))
        ]
      end

      def self.delete(headers, key)
        headers.reject { |k, _v| normalize_key(key) == k }
      end

      def self.pair(key, value)
        [normalize_key(key), value]
      end

      # As per RFC2616, headers names are case insensitive. This
      # function normalizes them to PascalCase acting on dashes ('-').
      #
      # When a rack server maps headers to CGI-like variables, both
      # dashes and underscores (`_`) are treated as dashes. This
      # function substitutes all '-' to '_'.
      #
      # See https://www.w3.org/Protocols/rfc2616/rfc2616-sec4.html#sec4.2
      def self.normalize_key(key)
        key.downcase.gsub("_", "-").split("-").map(&:capitalize).join("-")
      end

      def self.normalize(headers)
        headers.transform_keys { |k| normalize_key(k) }
      end
    end
  end
end

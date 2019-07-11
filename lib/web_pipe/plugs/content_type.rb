# frozen_string_literal: true

require 'web_pipe/types'

module WebPipe
  module Plugs
    # Sets `Content-Type` response header.
    #
    # @example
    #   class App
    #     include WebPipe
    #
    #     plug :html, WebPipe::Plugs::ContentType['text/html']
    #   end
    module ContentType
      # Content-Type header
      HEADER = 'Content-Type'

      def self.[](content_type)
        ->(conn) { conn.add_response_header(HEADER, content_type) }
      end
    end
  end
end

# frozen_string_literal: true

require "web_pipe"

# :nodoc:
module WebPipe
  # See the docs for the extension linked from the README.
  module Container
    # Returns {Conn#config} `:container` value
    #
    # @return [Any]
    def container
      fetch_config(:container)
    end
  end

  Conn.include(Container)
end

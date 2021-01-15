# frozen_string_literal: true

require 'web_pipe'

#:nodoc:
module WebPipe
  # Extension adding a `#container` method which returns {Conn#config}
  # `:container` key.
  #
  # @example
  #   require 'web_pipe'
  #
  #   WebPipe.load_extensions(:container)
  #
  #   class App
  #     include WebPipe
  #
  #     plug :container, ->(conn) { conn.add_config(:container, MyContainer) }
  #     plug :render, ->(conn) { conn.set_response_body(conn.container['view']) }
  #   end
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

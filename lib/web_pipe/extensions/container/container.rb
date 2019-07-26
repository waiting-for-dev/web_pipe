require 'web_pipe'

module WebPipe
  # Extension adding a `#container` method to fetch bag's `:container`
  # key.
  #
  # Usually, the container is set with {WebPipe::Plugs::Container}.
  #
  # @example
  #   require 'web_pipe'
  #   require 'web_pipe/extensions/container/plugs/container'
  #
  #   WebPipe.load_extensions(:container)
  #
  #   class App
  #     include WebPipe
  #
  #     plug :container, WebPipe::Plugs::Container[MyContainer]
  #     plug :render, ->(conn) { conn.set_response_body(conn.container['view']) }
  #   end
  class Conn < Dry::Struct
    # Returns bag `:container` value
    #
    # @return [Any]
    def container
      fetch(:container)
    end
  end
end

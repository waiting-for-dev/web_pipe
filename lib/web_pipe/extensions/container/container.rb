module WebPipe
  # Adds a `container` setting to {WebPipe::Conn} configuration.
  #
  # Besides the setting, a `.container` reader attribute is added to
  # {WebPipe::Conn}.
  #
  # This extension is meant to be a building block for other
  # extensions.
  #
  # @example
  #   WebPipe.load_extensions(:container)
  #
  #   Container = {'foo' => 'bar'}.freeze
  #
  #   WebPipe.config.container = Container
  #   WebPipe.container['foo'] # => 'bar'
  class Conn < Dry::Struct
    # Container with nothing registered.
    EMPTY_CONTAINER = {}.freeze

    setting(:container, EMPTY_CONTAINER, reader: true) do |c|
      Types::Container[c]
    end
  end
end

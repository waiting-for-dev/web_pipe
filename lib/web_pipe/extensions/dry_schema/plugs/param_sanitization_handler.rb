require 'web_pipe/types'

module WebPipe
  module Plugs
    # Sets `:param_sanitization_handler` bag key.
    #
    # @see WebPipe::DrySchema
    module ParamSanitizationHandler
      # Bag key to store the handler.
      #
      # @return [Symbol]
      PARAM_SANITIZATION_HANDLER_KEY = :param_sanitization_handler

      # Type constructor for the handler.
      Handler = Types.Interface(:call)

      # @param handler [Handler[]]
      #
      # @return [ConnSupport::Composition::Operation[]]
      def self.[](handler)
        lambda do |conn|
          conn.put(PARAM_SANITIZATION_HANDLER_KEY, Handler[handler])
        end
      end
    end
  end
end
require 'web_pipe/types'
require 'web_pipe/extensions/dry_schema/dry_schema'
require 'web_pipe/extensions/dry_schema/plugs/param_sanitization_handler'

module WebPipe
  module Plugs
    # Sanitize {Conn#params} with given `dry-schema` Schema.
    #
    # @see WebPipe::DrySchema
    module SanitizeParams
      # Default handler if none is configured nor injected.
      #
      # @return [ParamSanitizationHandler::Handler[]]
      DEFAULT_HANDLER = lambda do |conn, _result|
        conn.
          set_status(500).
          set_response_body('Given params do not conform with the expected schema').
          halt
      end

      # @param schema [Dry::Schema::Processor]
      # @param handler [ParamSanitizationHandler::Handler[]]
      #
      # @return [ConnSupport::Composition::Operation[], Types::Undefined]
      def self.[](schema, handler = Types::Undefined)
        lambda do |conn|
          result = schema.(conn.params)
          if result.success?
            conn.put(DrySchema::SANITIZED_PARAMS_KEY, result.output)
          else
            get_handler(conn, handler).(conn, result)
          end
        end
      end

      def self.get_handler(conn, handler)
        return handler unless handler == Types::Undefined

        conn.fetch(
          Plugs::ParamSanitizationHandler::PARAM_SANITIZATION_HANDLER_KEY, DEFAULT_HANDLER
        )
      end
      private_class_method :get_handler
    end
  end
end